local jwt = require "resty.jwt"

local public_key = os.getenv("PUBLIC_KEY")
if not public_key then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say("JWT public key not found in environment variables")
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end


-- Функция для проверки JWT токена
local function verify_jwt()
    local auth_header = ngx.var.http_authorization
    if not auth_header then
        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.say("Missing auth token")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
    if not token then
        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.say("Invalid auth header format")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local success, jwt_obj = pcall(function() return jwt:load_jwt(token) end)

    if not success or not jwt_obj  then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say("Invalid token format")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    if not jwt_obj.payload then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say("Missing payload in token")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    local verified = jwt:verify_jwt_obj(public_key, jwt_obj)

    if not verified then
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say("Invalid token")
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end

    local exp = jwt_obj.payload.exp
    if exp then
        local current_time = ngx.time()
        if exp < current_time then
            ngx.status = ngx.HTTP_UNAUTHORIZED
            ngx.say("Token has expired")
            ngx.exit(ngx.HTTP_UNAUTHORIZED)
        end
    else
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say("Token does not contain expiration field")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    -- Извлекаем данные из payload, например: user id и email
    local user_id = jwt_obj.payload.sub or nil
    if not user_id or not user_id then
        ngx.status = ngx.HTTP_BAD_REQUEST
        ngx.say("Missing or invalid 'sub' (user_id) in token")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    -- Прокидываем полученные данные в заголовки для дальнейшей обработки микросервисами
    ngx.req.set_header("X-User-Id", user_id)
end

-- Выполняем проверку
verify_jwt()
