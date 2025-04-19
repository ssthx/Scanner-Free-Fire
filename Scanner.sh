#!/bin/bash

# SCANNER BY THX
# ORGANIZAÇÃO ZE*

# Cores para terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Arquivo de log
LOG_FILE="./adb_security_scan.log"

# Verificar versão do Android
check_android_version() {
  echo -e "${YELLOW}[Sistema] Verificando versão do Android...${RESET}"
  android_version_sdk=$(adb shell getprop ro.build.version.sdk)
  android_version_name=$(adb shell getprop ro.build.version.release)
  echo -e "${GREEN}[Sistema] Versão do Android SDK: $android_version_sdk (${android_version_name})${RESET}" | tee -a "$LOG_FILE"
}

# Verificar root
check_root_status() {
  echo -e "${YELLOW}[Root] Verificando root...${RESET}"
  magisk=$(adb shell "pm list packages | grep 'com.topjohnwu.magisk'" 2>/dev/null)
  ksu=$(adb shell "pm list packages | grep 'com.koobee.ksu'" 2>/dev/null)
  ksu_next=$(adb shell "pm list packages | grep 'com.koobee.ksunext'" 2>/dev/null)

  if [ -n "$magisk" ]; then
    echo -e "${RED}[Root] Magisk Detectado!${RESET}" | tee -a "$LOG_FILE"
  elif [ -n "$ksu" ]; then
    echo -e "${RED}[Root] KSU Detectado!${RESET}" | tee -a "$LOG_FILE"
  elif [ -n "$ksu_next" ]; then
    echo -e "${RED}[Root] KSU Next Detectado!${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[Root] Nenhum root detectado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# Verificar Depuração USB
check_usb_debugging() {
  echo -e "${YELLOW}[USB] Verificando Depuração USB...${RESET}"
  connected=$(adb devices | grep -w "device")
  if [ -z "$connected" ]; then
    echo -e "${RED}[USB] Depuração USB INATIVA.${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[USB] Depuração USB ATIVA.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# Verificar MTP
check_mtp() {
  echo -e "${YELLOW}[MTP] Verificando conexão MTP...${RESET}"
  mtp_state=$(adb shell "svc usb getFunctions" 2>/dev/null)
  if [[ "$mtp_state" == *"mtp"* ]]; then
    echo -e "${GREEN}[MTP] MTP está ATIVO.${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[MTP] MTP está INATIVO ou não configurado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

check_shader_file() {
  echo -e "${YELLOW}[SHADER] Verificando arquivo shader...${RESET}"
  shader_dir="/sdcard/Android/data/com.dts.freefireth/files/contentcache/Optional/android/gameassetbundles/"
  latest_shader_file=$(adb shell "ls -S $shader_dir | grep 'shaders' | head -n 1")

  if [ -n "$latest_shader_file" ]; then
    echo -e "${GREEN}[SHADER] Arquivo shader encontrado: $latest_shader_file${RESET}" | tee -a "$LOG_FILE"
    shader_stat=$(adb shell "stat $shader_dir/$latest_shader_file")
    shader_mod_time=$(echo "$shader_stat" | grep "Modify" | awk '{print $2, $3}')
    echo -e "${GREEN}Última modificação: $shader_mod_time${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[SHADER] Arquivo shader não encontrado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""










}
# Verificar qualquer arquivo dentro da pasta .obb
check_obb_files() {
  echo -e "${YELLOW}[OBB] Procurando arquivos dentro da pasta .obb...${RESET}"
  obb_files=$(adb shell "find /sdcard/Android/obb/com.dts.freefireth/")

  if [ -n "$obb_files" ]; then
    echo -e "${GREEN}[OBB] Arquivos encontrados dentro da pasta .obb:${RESET}" | tee -a "$LOG_FILE"
    echo "$obb_files" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[OBB] Nenhum arquivo encontrado dentro da pasta .obb.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# Verificar arquivos relacionados a hack
check_hack_files() {
  echo -e "${YELLOW}[Hack] Verificando arquivos relacionados a Hack (XIT, HS):${RESET}"
  hack_files=$(adb shell find /sdcard -type f -iname "*xit*" -o -iname "*hs*" 2>/dev/null)

  if [ -n "$hack_files" ]; then
    echo -e "${RED}[Hack] Arquivos encontrados:${RESET}" | tee -a "$LOG_FILE"
    echo "$hack_files" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[Hack] Nenhum arquivo relacionado a XIT ou HS encontrado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# Verificar arquivos de replay
check_latest_mreplay_file() {
  echo -e "${YELLOW}[MReplays] Verificando arquivos mais recentes...${RESET}"
  dir="/sdcard/Android/data/com.dts.freefireth/files/MReplays"
  files=$(adb shell "ls -t $dir 2>/dev/null | grep -E '.json|.jhon|.bin$' | head -n 2")

  if [ -z "$files" ]; then
    echo -e "${RED}[MReplays] Nenhum arquivo encontrado.${RESET}" | tee -a "$LOG_FILE"
    return
  fi

  for file in $files; do
    full_path="$dir/$file"
    stat_out=$(adb shell "stat $full_path" 2>/dev/null)
    access_time=$(echo "$stat_out" | grep "Access" | awk '{print $2, $3}')
    modify_time=$(echo "$stat_out" | grep "Modify" | awk '{print $2, $3}')
    change_time=$(echo "$stat_out" | grep "Change" | awk '{print $2, $3}')

    echo -e "${GREEN}[MReplays] Arquivo encontrado:${RESET}" | tee -a "$LOG_FILE"
    echo -e "Nome: $file" | tee -a "$LOG_FILE"
    echo -e "Última modificação (Access): $access_time" | tee -a "$LOG_FILE"
    echo -e "Última modificação (Modify): $modify_time" | tee -a "$LOG_FILE"
    echo -e "Última modificação (Change): $change_time" | tee -a "$LOG_FILE"
    echo ""
  done
}

# Comparar datas de replay e .obb
check_obb_file_comparison() {
  echo -e "${YELLOW}[OBB] Comparando data/hora do replay e .obb...${RESET}"

  replay_dir="/sdcard/Android/data/com.dts.freefireth/files/MReplays"
  obb_file="/storage/emulated/0/Android/obb/com.dts.freefireth/"

  # Verificar o arquivo mais recente de replay
  latest_replay=$(adb shell "ls -t $replay_dir | grep -E '\.json|\.jhon|\.bin$' | head -n 1")
  replay_file="$replay_dir/$latest_replay"

  # Obter a data/hora do replay
  replay_stat=$(adb shell "stat \"$replay_file\"")
  replay_modify_time=$(echo "$replay_stat" | grep "Modify" | awk '{print $2, $3}')

  # Verificar o arquivo .obb
  obb_stat=$(adb shell "stat \"$obb_file\"")
  obb_modify_time=$(echo "$obb_stat" | grep "Modify" | awk '{print $2, $3}')

  # Comparar as datas
  if [ "$replay_modify_time" == "$obb_modify_time" ]; then
    echo -e "${GREEN}[OBB] A data/hora do replay e do arquivo .obb são as mesmas.${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[OBB] A data/hora do replay e do arquivo .obb são diferentes.${RESET}" | tee -a "$LOG_FILE"
  fi

  echo -e "Data/Hora do arquivo replay: $replay_modify_time" | tee -a "$LOG_FILE"
  echo -e "Data/Hora do arquivo .obb: $obb_modify_time" | tee -a "$LOG_FILE"
  echo ""
}
check_optionalavatarres() {
  echo -e "${YELLOW}[Pasta] Verificando data de alteração na pasta 'optionalavatarres'...${RESET}"
  dir="/sdcard/Android/data/com.dts.freefireth/files/optionalavatarres"
  stat_out=$(adb shell "stat $dir" 2>/dev/null)

  if [ $? -eq 0 ]; then
    mod_time=$(echo "$stat_out" | grep "Modify" | awk '{print $2, $3}')
    echo -e "${GREEN}[Pasta] Data de alteração: $mod_time${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[Pasta] Pasta 'optionalavatarres' não encontrada.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# Verificar acessos do Google Play
check_google_play_access() {
  echo -e "${YELLOW}[Play Store] Verificando últimos acessos do Google Play Store...${RESET}"
  play_store_logs=$(adb shell "logcat -d | grep 'GooglePlay' | tail -n 3")

  if [ -n "$play_store_logs" ]; then
    echo -e "${GREEN}[Play Store] Últimos acessos:${RESET}" | tee -a "$LOG_FILE"
    echo "$play_store_logs" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[Play Store] Nenhum acesso recente registrado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# Verificar modificação na pasta 'android'
check_android_folder_modification() {
  echo -e "${YELLOW}[Pasta] Verificando data de modificação na pasta 'android'...${RESET}"
  dir="/sdcard/Android/data/com.dts.freefireth/files/contentcache/Optional/android"
  stat_out=$(adb shell "stat $dir" 2>/dev/null)

  if [ $? -eq 0 ]; then
    mod_time=$(echo "$stat_out" | grep "Modify" | awk '{print $2, $3}')
    echo -e "${GREEN}[Pasta] Data de modificação: $mod_time${RESET}" | tee -a "$LOG_FILE"
  else
    echo -e "${RED}[Pasta] Pasta 'android' não encontrada.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
  }
check_running_apps() {
  echo -e "${YELLOW}[1] Apps em execução (INSTALADOS PELO USUÁRIO):${RESET}" | tee -a "$LOG_FILE"

  user_apps=$(adb shell pm list packages -3 | sed 's/package://g')
  running_processes=$(adb shell ps -A | grep u0_ | awk '{print $9}' | sort -u)

  for pkg in $running_processes; do
    if echo "$user_apps" | grep -qx "$pkg"; then
      echo -e "${GREEN}[Rodando] $pkg${RESET}" | tee -a "$LOG_FILE"
    fi
  done
  echo ""
}

# 2. Verificar apps desativados
check_disabled_apps() {
  echo -e "${YELLOW}[2] Apps DESATIVADOS pelo sistema:${RESET}" | tee -a "$LOG_FILE"
  adb shell pm list packages -d | sed 's/package://g' | tee -a "$LOG_FILE"
  echo ""
}

# 3. Verificar apps congelados (apk instalado + desativado)
check_frozen_apps() {
  echo -e "${YELLOW}[3] Apps CONGELADOS (apk instalado + desativado):${RESET}" | tee -a "$LOG_FILE"

  all_apps=$(adb shell pm list packages -f | sed 's/package://g')
  disabled_apps=$(adb shell pm list packages -d | sed 's/package://g')

  for pkg in $disabled_apps; do
    apk_path=$(echo "$all_apps" | grep "$pkg" | cut -d "=" -f1)
    if [[ -n "$apk_path" ]]; then
      echo -e "${GREEN}[Congelado] $pkg (${apk_path})${RESET}" | tee -a "$LOG_FILE"
    fi
  done
  echo ""
}

# 4. Verificar apps ocultos (sem launcher)
check_hidden_apps() {
  echo -e "${YELLOW}[4] Apps OCULTOS (sem ícone de launcher):${RESET}" | tee -a "$LOG_FILE"

  all_packages=$(adb shell pm list packages | sed 's/package://g')

  for pkg in $all_packages; do
    launcher=$(adb shell cmd package resolve-activity --brief "$pkg" 2>/dev/null | tail -n 1)
    if [[ "$launcher" == "no activities found" ]]; then
      echo -e "${RED}[Oculto] $pkg${RESET}" | tee -a "$LOG_FILE"
    fi
  done
  echo ""
}
check_metadata() {
  echo -e "${YELLOW}[8] Verificando pasta de metadados:${RESET}" | tee -a "$LOG_FILE"

  # Verificando se existe a pasta que pode armazenar metadados suspeitos
  metadata_dir="/sdcard/Android/data/com.dts.freefireth/files/metadata"
  
  if [ -d "$metadata_dir" ]; then
    echo -e "${RED}[Metadados] Pasta de metadados encontrada:${RESET}" | tee -a "$LOG_FILE"
    echo "$metadata_dir" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}Conteúdo da pasta:${RESET}" | tee -a "$LOG_FILE"
    ls -l "$metadata_dir" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[Metadados] Pasta de metadados não encontrada.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# 7. Verificar arquivos e pastas no diretório /sdcard
check_sdcard_files() {
  echo -e "${YELLOW}[9] Verificando arquivos e pastas em /sdcard:${RESET}" | tee -a "$LOG_FILE"

  # Verificar o conteúdo completo de /sdcard
  sdcard_content=$(ls -lR /sdcard)

  if [ -n "$sdcard_content" ]; then
    echo -e "${RED}[SDCard] Conteúdo de /sdcard encontrado:${RESET}" | tee -a "$LOG_FILE"
    echo "$sdcard_content" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[SDCard] Nenhum arquivo encontrado em /sdcard.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# 8. Verificar arquivos de hacks escondidos (nome de arquivos suspeitos)
check_suspect_files() {
  echo -e "${YELLOW}[10] Verificando arquivos suspeitos em /sdcard:${RESET}" | tee -a "$LOG_FILE"

  # Procurando por arquivos com nomes suspeitos (ex.: hack, mod, etc.)
  suspect_files=$(find /sdcard -type f -iname "*hack*" -o -iname "*mod*" -o -iname "*cheat*")

  if [ -n "$suspect_files" ]; then
    echo -e "${RED}[Suspeitos] Arquivos encontrados:${RESET}" | tee -a "$LOG_FILE"
    echo "$suspect_files" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[Suspeitos] Nenhum arquivo suspeito encontrado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}

# 9. Verificar arquivos executáveis em /sdcard (possíveis exploits)
check_executable_files() {
  echo -e "${YELLOW}[11] Verificando arquivos executáveis em /sdcard:${RESET}" | tee -a "$LOG_FILE"

  # Procurando por arquivos executáveis (.apk, .exe, etc.)
  executable_files=$(find /sdcard -type f -iname "*.apk" -o -iname "*.exe" -o -iname "*.so")

  if [ -n "$executable_files" ]; then
    echo -e "${RED}[Executáveis] Arquivos encontrados:${RESET}" | tee -a "$LOG_FILE"
    echo "$executable_files" | tee -a "$LOG_FILE"
  else
    echo -e "${GREEN}[Executáveis] Nenhum arquivo executável encontrado.${RESET}" | tee -a "$LOG_FILE"
  fi
  echo ""
}
# Verificar alterações em arquivos nos últimos 10 dias
check_recent_file_changes() {
  local pasta_alvo="/sdcard/Android/data/com.dts.freefireth"  # Altere para o caminho desejado
  echo -e "${YELLOW}[Sistema] Verificando arquivos modificados, criados ou excluídos nos últimos 10 dias em: $pasta_alvo...${RESET}"

  if [ ! -d "$pasta_alvo" ]; then
    echo -e "${RED}[Erro] Pasta não encontrada: $pasta_alvo${RESET}"
    return 1
  fi

  echo -e "${BLUE}[Info] Arquivos modificados ou criados nos últimos 10 dias:${RESET}"
  find "$pasta_alvo" -type f -mtime -10 -print | tee -a "$LOG_FILE"

  echo -e "${BLUE}[Info] Pastas modificadas nos últimos 10 dias:${RESET}"
  find "$pasta_alvo" -type d -mtime -10 -print | tee -a "$LOG_FILE"
}

# Observação: Para detectar arquivos excluídos, seria necessário comparar com um snapshot anterior (ex: lista salva em um .txt).






# Rodar todas verificações
run_scan() {
  echo -e "${BLUE}====== INÍCIO DA VERIFICAÇÃO ======${RESET}" | tee -a "$LOG_FILE"
  check_android_version
  check_root_status
  check_usb_debugging
  check_mtp
check_shader_file
  check_hack_files
  check_latest_mreplay_file
  check_obb_file_comparison
check_android_folder_modification
check_google_play_access
check_optionalavatarres
check_running_apps
  check_disabled_apps
  check_frozen_apps
  check_hidden_apps
check_metadata
check_sdcard_files
check_suspect_files
check_executable_files
check_recent_file_changes

  echo -e "${BLUE}====== FIM DA VERIFICAÇÃO ======${RESET}" | tee -a "$LOG_FILE"
}

# Verificar acesso ao log
if ! touch "$LOG_FILE" 2>/dev/null; then
  echo -e "${RED}[ERRO] Não foi possível criar ou acessar o arquivo de log.${RESET}"
  exit 1
fi

# Iniciar o scanner
run_scan
