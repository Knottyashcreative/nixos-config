{ pkgs, ... }:
{
  services.comfyui = {
    enable = true;
    host = "0.0.0.0";
    acceleration = "cuda";
    models =  [
      pkgs.nixified-ai.models.flux-ae
      pkgs.nixified-ai.models.flux1-dev-q4_0
      pkgs.nixified-ai.models.flux-text-encoder-1
      pkgs.nixified-ai.models.t5-v1_1-xxl-encoder
    ];
    customNodes = with pkgs.comfyui.pkgs; [
      comfyui-gguf
#      comfyui-impact-pack
    ];
  };
}
