package ru.nsu.geoapp.ms_users.services;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.SecureDigestAlgorithm;
import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;
import ru.nsu.geoapp.ms_users.model.User;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Arrays;
import java.util.Base64;
import java.util.Date;

@Service
public class JwtTokenService {

    private final PrivateKey privateKey;
    private final PublicKey publicKey;
    private final long jwtExpiration;
    private final long jwtExpirationRefresh;
    @Getter
    private final UserService userService;

    private static final Logger LOGGER = LoggerFactory.getLogger(JwtTokenService.class);

    public JwtTokenService(
            @Value("${app.jwt.expiration}") long jwtExpiration,
            @Value("${app.jwt.expiration-refresh}") long jwtExpirationRefresh,
            UserService userService
    ) throws IOException, NoSuchAlgorithmException, InvalidKeySpecException {
        this.jwtExpiration = jwtExpiration;
        this.jwtExpirationRefresh = jwtExpirationRefresh;
        this.userService = userService;
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

    public JwtToken generateAccessToken(String subject) {
        return this.generateToken(subject, false);
    }

    public JwtToken generateRefreshToken(String subject) {
        return this.generateToken(subject, true);
    }

    private JwtToken generateToken(String subject, boolean isRefresh) {
        Date now = new Date();
        Date expiryDate;
        if (isRefresh) {
            expiryDate = new Date(now.getTime() + jwtExpirationRefresh);
        } else {
            expiryDate = new Date(now.getTime() + jwtExpiration);
        }

        JwtToken token = new JwtToken();
        token.setSubject(subject);
        token.setIssuedAt(now);
        token.setExpiryDate(expiryDate);
        token.setRefresh(isRefresh);
        token.signWith(privateKey, Jwts.SIG.RS256, "RS256");
        return token;
    }

    public String getPublicKey() {
        byte[] encoded = publicKey.getEncoded();
        String base64 = Base64.getEncoder().encodeToString(encoded);

        StringBuilder result = new StringBuilder();
        for (int i = 0; i < base64.length(); i += 64) {
            int end = Math.min(base64.length(), i + 64);
            result.append(base64, i, end);
            if (end != base64.length()) {
                result.append("\n");
            }
        }

        return "-----BEGIN PUBLIC KEY-----\n" +
                result +
                "\n-----END PUBLIC KEY-----";
    }

    public boolean isAccessToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(this.publicKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return !((boolean) claims.get("isRefresh"));
    }

    public String getSubjectFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(this.publicKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return claims.getSubject();
    }

    public Date getExpirationDateFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(this.publicKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return claims.getExpiration();
    }

    public Date getIssuedDateFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(this.publicKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return claims.getIssuedAt();
    }

    public boolean validateToken(String token) {
        try {
            LOGGER.debug("Validating {}", token);
            Claims claims = Jwts.parser().verifyWith(this.publicKey).build().parseSignedClaims(token).getPayload();
            // token is signed ad expiration date is okay
            // check for revoked date with Redis
            String subject = claims.getSubject();
            Date issuedAt = claims.getIssuedAt();
            LOGGER.debug("{} Token is valid, checking revoked", token);
            User user = this.userService.findBySubject(subject);
            if (user == null) {
                LOGGER.debug("user not found {}.", subject);
                return false;
            }
            boolean isRevoked = issuedAt.getTime() <= user.getRevokedUTC() / 1000;
            if (isRevoked) {
                LOGGER.debug("{} Token is revoked.", token);
            }
            return !isRevoked;
        } catch (Exception ex) {
            LOGGER.debug("Exception while verifying token {}: {}", token, ex.getMessage());
            return false;
        }
    }

    public static class JwtToken {
        private static int shortenedSize = 5;
        @Setter
        @Getter
        private String subject;
        @Setter
        @Getter
        private Date issuedAt;
        @Setter
        @Getter
        private Date expiryDate;
        private boolean isRefresh = false;

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
                    .claim("isRefresh", isRefresh)
                    .signWith(key, algo)
                    .compact();
        }

        public boolean isRefresh() {
            return isRefresh;
        }

        public void setRefresh(boolean refresh) {
            isRefresh = refresh;
        }

        public String toString() {
            if (this.signedString == null) {
                return null;
            }

            if (this.signedString.length() <= 2 * shortenedSize) {
                return this.signedString;
            }

            String beginning = this.signedString.substring(0, shortenedSize);
            String end = this.signedString.substring(this.signedString.length() - shortenedSize);
            return beginning + "..." + end;
        }
    }
}
