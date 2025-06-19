package main

import "ms_events_go/internal/app/events_app"

const configFilePath = "./configs/.env"

func main() {
	events_app.Run(configFilePath)
}
