package ru.nsu.geoapp.ms_users;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.SecureDigestAlgorithm;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.Date;

@Service
public class JwtTokenProvider {

    private final PrivateKey privateKey;
    private final PublicKey publicKey;
    private final long jwtExpiration;

    public JwtTokenProvider(@Value("${app.jwt.expiration}") long jwtExpiration) throws IOException, NoSuchAlgorithmException, InvalidKeySpecException {
        this.jwtExpiration = jwtExpiration;
        this.privateKey = loadPrivateKey("keys/private_key.pem");
        this.publicKey = loadPublicKey("keys/public_key.pem");
    }

    private PrivateKey loadPrivateKey(String filename) throws IOException, NoSuchAlgorithmException, InvalidKeySpecException {
        String key = Files.readString(Path.of(new ClassPathResource(filename).getURI()))
                .replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replaceAll("\\s", "");

        byte[] decoded = Base64.getDecoder().decode(key);
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(decoded);
        return KeyFactory.getInstance("RSA").generatePrivate(keySpec);
    }

    private PublicKey loadPublicKey(String filename) throws IOException, NoSuchAlgorithmException, InvalidKeySpecException {
        // Чтение файла из ресурсов
        String key = Files.readString(Path.of(new ClassPathResource(filename).getURI()))
                .replace("-----BEGIN PUBLIC KEY-----", "")
                .replace("-----END PUBLIC KEY-----", "")
                .replaceAll("\\s", "");

        byte[] decoded = Base64.getDecoder().decode(key);
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(decoded);
        return KeyFactory.getInstance("RSA").generatePublic(keySpec);
    }

    public JwtToken generateToken(String email) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);

        JwtToken token = new JwtToken();
        token.setSubject(email);
        token.setIssuedAt(now);
        token.setExpiryDate(expiryDate);
        token.signWith(privateKey, Jwts.SIG.RS256, "RS256");
        return token;
    }

    public String getEmailFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(this.publicKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return claims.getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(this.publicKey).build().parseSignedClaims(token);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }

    public static class JwtToken {
        private String subject;
        private Date issuedAt;
        private Date expiryDate;

        public String getSubject() {
            return subject;
        }

        public void setSubject(String subject) {
            this.subject = subject;
        }

        public Date getIssuedAt() {
            return issuedAt;
        }

        public void setIssuedAt(Date issuedAt) {
            this.issuedAt = issuedAt;
        }

        public Date getExpiryDate() {
            return expiryDate;
        }

        public void setExpiryDate(Date expiryDate) {
            this.expiryDate = expiryDate;
        }

        private String signedString = null;

        public String asString() {
            return signedString;
        }

        public <K extends Key> void signWith(K key, SecureDigestAlgorithm<? super K, ?> algo, String algoName) {
            this.signedString = Jwts.builder()
                    .header()
                    .add("typ", "JWT")
                    .add("alg", algoName)
                    .and()
                    .subject(subject)
                    .issuedAt(issuedAt)
                    .expiration(expiryDate)
                    .signWith(key, algo)
                    .compact();
        }
    }
}
