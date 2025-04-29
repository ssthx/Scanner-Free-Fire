#!/system/bin/sh

# Pasta de origem
pasta_origem="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents/"

# Pasta de destino
pasta_destino="/storage/emulated/0/Android/data/com.dts.freefireth/files/MReplays/"

# Verifica se a pasta de destino existe, se não, cria
adb shell mkdir -p "$pasta_destino"

# Loop infinito para mover arquivos periodicamente
while true
do
  for arquivo in $(adb shell ls "$pasta_origem"); do
    # Verifica se o arquivo tem extensão .bin ou .json
    case "$arquivo" in
      *.bin|*.json)
        # Extrai o nome do arquivo
        nome_arquivo=$(basename "$arquivo")
        
        # Extrair data e hora do nome (formato: YYYY-MM-DD-HH-MM-SS_nome.ext)
        dataehora=$(echo "$nome_arquivo" | cut -d'_' -f1 | tr -d '-' | cut -c1-14)

        if [ "$(echo $dataehora | wc -c)" -eq 15 ]; then
          # Formato para data e hora
          dataehora_com_ponto="$(echo $dataehora | cut -c1-12).$(echo $dataehora | cut -c13-14)"

          # Move o arquivo para a pasta de destino
          adb shell mv "$pasta_origem/$nome_arquivo" "$pasta_destino/"

          # Tenta alterar a data de modificação (pode não funcionar em /sdcard)
          adb shell touch -t "$dataehora_com_ponto" "$pasta_destino/$nome_arquivo" 2>/dev/null

          echo "Arquivo $nome_arquivo movido para $pasta_destino com timestamp $dataehora_com_ponto"
        else
          echo "Erro ao extrair data/hora de $nome_arquivo"
        fi
        ;;
    esac
  done

  # Aguarda 1 segundo antes de verificar novamente
  sleep 1
done