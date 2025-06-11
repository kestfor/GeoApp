package ru.nsu.geoapp.ms_users.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.PublicKey;
import java.util.Collections;

@Service
public class GoogleTokenVerifier {

    private static final String GOOGLE_CLIENT_ID = "659561258557-7vnkeva48n8oga6s07bpaoob4pecbdgg.apps.googleusercontent.com";
    private static final String GOOGLE_CLIENT_ID_IOS = "659561258557-fmdull5cmmshmbvsk5u25p4c4pgncvu6.apps.googleusercontent.com";

    private static final Logger LOGGER = LoggerFactory.getLogger(GoogleTokenVerifier.class);

    public GoogleIdToken.Payload verify(String idTokenString) throws Exception {
        // Первый верификатор с Android-клиентом
        GoogleIdTokenVerifier androidVerifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance())
                .setAudience(Collections.singletonList(GOOGLE_CLIENT_ID))
                .build();

        GoogleIdToken idToken = null;

        try {
            idToken = androidVerifier.verify(idTokenString);
            if (idToken != null) {
                // Успешно верифицировано Android-client_id
                return idToken.getPayload();
            } else {
                LOGGER.debug("Android verifier returned null (token not valid for Android client).");
            }
        } catch (Exception e) {
            LOGGER.error("Android client ID verification failed: {}", e.getMessage());
        }

        // Если мы дошли сюда, значит верификация с Android-client_id не прошла
        LOGGER.debug("Attempting verification with iOS client ID...");

        GoogleIdTokenVerifier iosVerifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance())
                .setAudience(Collections.singletonList(GOOGLE_CLIENT_ID_IOS))
                .build();

        try {
            idToken = iosVerifier.verify(idTokenString);
            if (idToken != null) {
                // Успешно верифицировано iOS-client_id
                return idToken.getPayload();
            } else {
                LOGGER.debug("iOS verifier returned null (token not valid for iOS client).");
                this.inspectFailedToken(iosVerifier, idTokenString);
                throw new RuntimeException("Invalid Google ID token for both Android and iOS client IDs");
            }
        } catch (Exception e) {
            LOGGER.error("iOS client ID verification failed: {}", e.getMessage());
            throw e;
        }
    }


    private void inspectFailedToken(GoogleIdTokenVerifier verifier, String idTokenString) throws IOException, GeneralSecurityException {
        GoogleIdToken unsignedToken = GoogleIdToken.parse(
                GsonFactory.getDefaultInstance(),
                idTokenString
        );

        if (verifier.getIssuers() == null) {
            LOGGER.debug("verifier.getIssuers() is null");
        } else {
            LOGGER.debug("unsignedToken.verifyIssuer(verifier.getIssuers()): {}", unsignedToken.verifyIssuer(verifier.getIssuers()));
        }

        if (verifier.getAudience() == null) {
            LOGGER.debug("verifier.getAudience() is null");
        } else {
            LOGGER.debug("unsignedToken.verifyAudience(verifier.getAudience()): {}", unsignedToken.verifyAudience(verifier.getAudience()));
        }

        LOGGER.debug("unsignedToken.verifyTime(): {}", unsignedToken.verifyTime(verifier.getClock().currentTimeMillis(), verifier.getAcceptableTimeSkewSeconds()));
        LOGGER.debug("verifier.getClock().currentTimeMillis(): {}", verifier.getClock().currentTimeMillis());
        LOGGER.debug("verifier.getAcceptableTimeSkewSeconds(): {}", verifier.getAcceptableTimeSkewSeconds());

        for (PublicKey publicKey : verifier.getPublicKeysManager().getPublicKeys()) {
            LOGGER.debug("Public key: {}", publicKey);
            LOGGER.debug("Verified: {}", unsignedToken.verifySignature(publicKey));
        }

        GoogleIdToken.Payload payload = unsignedToken.getPayload();
        LOGGER.debug("aud: {}", payload.getAudience());
        LOGGER.debug("exp: {}", payload.getExpirationTimeSeconds());
    }
}
