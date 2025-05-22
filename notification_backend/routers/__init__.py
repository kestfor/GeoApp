from .fcm import routers as fcm_routers
from .secure_docs import routers as secure_docs_routers
from .tokens import routers as tokens_routers

routers = [*secure_docs_routers, *fcm_routers, *tokens_routers]
