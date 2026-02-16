using System.Security.Cryptography;
using System.Text;

namespace EcoBackend.API.Services;

/// <summary>
/// Handles encryption and decryption of profile pictures using AES-256-CBC.
/// Key is derived from the JWT secret via SHA-256, matching the Python Fernet approach.
/// </summary>
public class ProfilePictureEncryptionService
{
    private readonly byte[] _key;
    private readonly string _mediaPath;

    public ProfilePictureEncryptionService(IConfiguration configuration)
    {
        // Derive encryption key from JWT secret (same source as Python's SECRET_KEY)
        var secret = configuration["JWT:Secret"] 
            ?? "your-secret-key-here-min-32-chars-long-replace-in-production!";
        _key = SHA256.HashData(Encoding.UTF8.GetBytes(secret)); // 32 bytes = AES-256
        _mediaPath = Path.Combine(Directory.GetCurrentDirectory(), "media", "profile_pictures");
        Directory.CreateDirectory(_mediaPath);
    }

    /// <summary>
    /// Encrypt file content using AES-256-CBC with a random IV prepended to the output.
    /// </summary>
    public byte[] Encrypt(byte[] plainContent)
    {
        using var aes = Aes.Create();
        aes.Key = _key;
        aes.GenerateIV();
        aes.Mode = CipherMode.CBC;
        aes.Padding = PaddingMode.PKCS7;

        using var encryptor = aes.CreateEncryptor();
        var encrypted = encryptor.TransformFinalBlock(plainContent, 0, plainContent.Length);

        // Prepend IV (16 bytes) to the encrypted data so we can decrypt later
        var result = new byte[aes.IV.Length + encrypted.Length];
        Buffer.BlockCopy(aes.IV, 0, result, 0, aes.IV.Length);
        Buffer.BlockCopy(encrypted, 0, result, aes.IV.Length, encrypted.Length);
        return result;
    }

    /// <summary>
    /// Decrypt file content. Expects the first 16 bytes to be the IV.
    /// </summary>
    public byte[] Decrypt(byte[] encryptedContent)
    {
        using var aes = Aes.Create();
        aes.Key = _key;
        aes.Mode = CipherMode.CBC;
        aes.Padding = PaddingMode.PKCS7;

        // Extract IV from the first 16 bytes
        var iv = new byte[16];
        Buffer.BlockCopy(encryptedContent, 0, iv, 0, 16);
        aes.IV = iv;

        using var decryptor = aes.CreateDecryptor();
        return decryptor.TransformFinalBlock(encryptedContent, 16, encryptedContent.Length - 16);
    }

    /// <summary>
    /// Generate a secure hashed filename for the encrypted profile picture.
    /// </summary>
    public string GenerateSecureFilename(int userId, string originalFilename)
    {
        var input = $"{userId}_{originalFilename}_{Convert.ToBase64String(_key)}";
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(input));
        var hashString = Convert.ToHexString(hash)[..16].ToLower();
        var ext = Path.GetExtension(originalFilename);
        return $"{hashString}{ext}.enc";
    }

    /// <summary>
    /// Save encrypted file to disk.
    /// </summary>
    public async Task<string> SaveEncryptedFileAsync(byte[] fileContent, int userId, string originalFilename)
    {
        var encrypted = Encrypt(fileContent);
        var secureFilename = GenerateSecureFilename(userId, originalFilename);
        var filePath = Path.Combine(_mediaPath, secureFilename);
        await File.WriteAllBytesAsync(filePath, encrypted);
        return secureFilename;
    }

    /// <summary>
    /// Read and decrypt a file from disk.
    /// </summary>
    public async Task<byte[]?> ReadDecryptedFileAsync(string filePath)
    {
        if (!File.Exists(filePath))
            return null;

        var encrypted = await File.ReadAllBytesAsync(filePath);
        return Decrypt(encrypted);
    }

    /// <summary>
    /// Get the full path to the profile pictures directory.
    /// </summary>
    public string GetMediaPath() => _mediaPath;

    /// <summary>
    /// Ensure a default encrypted profile picture exists.
    /// Reads blank-profile-picture.png from the media folder, encrypts it, and saves as default-encrypted.png.enc.
    /// </summary>
    public async Task EnsureDefaultProfilePictureAsync()
    {
        var defaultEncPath = Path.Combine(_mediaPath, "default-encrypted.png.enc");
        if (File.Exists(defaultEncPath))
            return;

        var sourcePath = Path.Combine(_mediaPath, "blank-profile-picture.png");
        if (!File.Exists(sourcePath))
            throw new FileNotFoundException(
                "Default profile picture not found. Ensure blank-profile-picture.png exists in media/profile_pictures/",
                sourcePath);

        var pngBytes = await File.ReadAllBytesAsync(sourcePath);
        var encrypted = Encrypt(pngBytes);
        await File.WriteAllBytesAsync(defaultEncPath, encrypted);
    }

    /// <summary>
    /// Get the decrypted default profile picture bytes.
    /// </summary>
    public async Task<byte[]?> GetDefaultProfilePictureAsync()
    {
        var defaultPath = Path.Combine(_mediaPath, "default-encrypted.png.enc");
        return await ReadDecryptedFileAsync(defaultPath);
    }
}
