from .files import routers as file_routers
from .secure_docs import routers as secure_docs_routers
from .upload_urls import routers as upload_urls_routers

routers = [*file_routers, *upload_urls_routers, *secure_docs_routers]
