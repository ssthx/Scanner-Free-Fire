#!/bin/bash

# Pasta de origem no dispositivo
pasta_origem="/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents/"

# Pasta de destino no dispositivo
pasta_destino="/sdcard/Android/data/com.dts.freefireth/files/MReplays/"

# Cria a pasta de destino, se não existir
adb shell "mkdir -p '$pasta_destino'"

# Loop infinito
while true; do
  # Lista os arquivos na pasta de origem
  arquivos=$(adb shell "ls '$pasta_origem'" 2>/dev/null)

  # Itera sobre os arquivos
  for arquivo in $arquivos; do
    if [[ "$arquivo" == *.bin || "$arquivo" == *.json ]]; then
      # Extrai nome base do arquivo
      nome_arquivo=$(basename "$arquivo")

      # Extrai data e hora (formato: YYYYMMDDHHMMSS)
      dataehora=$(echo "$nome_arquivo" | cut -d'_' -f1 | tr -d '-' | cut -c1-14)

      if [ "${#dataehora}" -eq 14 ]; then
        # Converte para o formato do comando touch (YYYYMMDDHHMM.SS)
        dataehora_formatado="$(echo "$dataehora" | cut -c1-12).$(echo "$dataehora" | cut -c13-14)"

        # Move o arquivo
        adb shell "mv '$pasta_origem/$nome_arquivo' '$pasta_destino/'"

        # Atualiza a data de modificação (pode não funcionar em todos os sistemas de arquivos)
        adb shell "touch -t '$dataehora_formatado' '$pasta_destino/$nome_arquivo'" 2>/dev/null

        echo "Movido: $nome_arquivo com timestamp $dataehora_formatado"
      else
        echo "Erro ao extrair data/hora de: $nome_arquivo"
      fi
    fi
  done

  sleep 1
done