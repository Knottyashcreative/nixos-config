{ config, ... }:
{
 services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [
      "deepseek-r1:14b"
    ];
  };
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    environment = {
      OLLAMA_API_BASE_URL = "http://${config.services.ollama.host}:${toString config.services.ollama.port}";
      WEBUI_AUTH = "False";
      PDF_EXTRACT_IMAGES = "true";
      ENABLE_SEARCH_QUERY = "true";
      ENABLE_RAG_WEB_SEARCH = "true";
      RAG_WEB_SEARCH_ENGINE = "duckduckgo";
    };
  };
}
