package ru.nsu.geoapp.ms_users;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class RedisTokenService {
    private static final String REVOKE_KEY_PREFIX = "token_revoked:";
    private final StringRedisTemplate redisTemplate;

    public RedisTokenService(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public void revokeAllTokensForUser(String subject) {
        revokeAllTokensForUser(subject, 0, TimeUnit.SECONDS);
    }

    public void revokeAllTokensForUser(String subject, long ttl, TimeUnit timeUnit) {
        long currentTime = System.currentTimeMillis();
        String key = REVOKE_KEY_PREFIX + subject;
        redisTemplate.opsForValue().set(key, String.valueOf(currentTime));

        if (ttl > 0) {
            redisTemplate.expire(key, ttl, timeUnit);
        }
    }

    public Long getLastRevocationTime(String subject) {
        String timeStr = redisTemplate.opsForValue().get(REVOKE_KEY_PREFIX + subject);
        return timeStr != null ? Long.parseLong(timeStr) : null;
    }

    public boolean isTokenRevoked(String subject, long tokenIssuedAt) {
        Long lastRevokeTime = getLastRevocationTime(subject);
        return lastRevokeTime != null && tokenIssuedAt <= lastRevokeTime;
    }
}
