terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
	  version = "~> 0.100"
    }
  }
  required_version = ">= 1.0"
}

provider "yandex" {
  zone = "ru-central1-d"
  cloud_id = "b1gb8o1l4upnhbj7vi1e"
  folder_id = "b1gn8a9539lodt8emh4r"
  service_account_key_file = "key.json"
}