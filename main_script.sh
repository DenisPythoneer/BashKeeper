#!/bin/bash

Success="\e[1;32m[+]\e[0m"
Error="\e[31m[-]\e[0m"
Info="\e[1;34m[*]\e[0m"

# Функции.

ctrl_c_handler() { # Обработка нажатия Ctrl+C.
    echo " "
    echo -e "\n\033[1;31m[!] Прервано пользователем (Ctrl+C)\033[0m"
    exit 1
}


exit_0(){
    echo " "
    echo -e "\033[1;33mДо свидания!\033[0m"

    exit
}


package_update(){
    echo " "
    echo -e "$Info Обновление списка пакетов..."
    
    if command -v apt &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
        echo " "
        sudo apt update

    elif command -v dnf &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
        echo " "
        sudo dnf check-update

    elif command -v pacman &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Pacman (Arch Linux)"
        echo " "
        sudo pacman -Sy

    elif command -v zypper &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Zypper (openSUSE)"
        echo " "
        sudo zypper refresh

    else
        echo " "
        echo -e "$Error Ошибка: Неизвестный пакетный менеджер!"
        exit 1
    fi
    
    echo " "
    echo -e "$Success Список пакетов обновлён!"

    sleep 3
    main
}


package_upgrade() {
    echo " "
    echo -e "$Info Обновление всех установленных пакетов..."
    
    if command -v apt &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
        echo " "
        sudo apt update && sudo apt upgrade -y
        sudo apt autoremove -y

    elif command -v dnf &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
        echo " "
        sudo dnf upgrade -y
        sudo dnf autoremove -y

    elif command -v pacman &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Pacman (Arch Linux)"
        echo " "
        sudo pacman -Syu --noconfirm

    elif command -v zypper &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Zypper (openSUSE)"
        echo " "
        sudo zypper update -y

    else
        echo " "
        echo -e "$Error Ошибка: Неизвестный пакетный менеджер!"
        exit 1
    fi
    
    echo " "
    echo -e "$Success Все пакеты успешно обновлены!"

    sleep 3
    main
}


clean_dependencies() {
    echo ""
    echo -e "$Info Очистка ненужных зависимостей..."

    if command -v apt &> /dev/null; then
        echo ""
        echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
        echo " "
        echo -e "$Info Удаление ненужных пакетов..."
        echo " "
        sudo apt autoremove -y
        echo " "
        echo -e "$Info Очистка кеша..."
        echo " "
        sudo apt clean

    elif command -v dnf &> /dev/null; then
        echo ""
        echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
        echo " "
        echo -e "$Info Удаление ненужных пакетов..."
        echo " "
        sudo dnf autoremove -y
        echo " "
        echo -e "$Info Очистка кеша..."
        echo " "
        sudo dnf clean all

    elif command -v pacman &> /dev/null; then
        echo ""
        echo -e "$Info Обнаружен Pacman (Arch Linux)"
        echo " "
        echo -e "$Info Удаление ненужных пакетов..."
        echo " "
        sudo pacman -Rns $(pacman -Qdtq) --noconfirm 2>/dev/null || echo "Нет пакетов для удаления"
        echo " "
        echo -e "$Info Очистка кеша..."
        echo " "
        sudo pacman -Sc --noconfirm

    elif command -v zypper &> /dev/null; then
        echo ""
        echo -e "$Info Обнаружен Zypper (openSUSE)"
        echo " "
        echo -e "$Info Удаление ненужных пакетов..."
        echo " "
        sudo zypper packages --unneeded | awk -F'|' '/^i/ {print $2}' | xargs -r sudo zypper remove -y
        echo " " 
        echo -e "$Info Очистка кеша..."
        echo " "
        sudo zypper clean

    else
        echo " "
        echo -e "$Error Ошибка: Неизвестный пакетный менеджер!"
        exit 1
    fi

    echo " "
    echo -e "$Success Все ненужные пакеты были удачно удалены!"

    sleep 3
    main
}


package_cache_clean() {
    echo " "
    echo -e "$Info Очистка кеша пакетов..."
    
    if command -v apt &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
        echo " "
        sudo apt clean
        sudo apt autoclean

    elif command -v dnf &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
        sudo dnf clean all

    elif command -v pacman &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Pacman (Arch Linux)"
        echo " "
        sudo pacman -Scc --noconfirm

    elif command -v zypper &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Zypper (openSUSE)"
        echo " "
        sudo zypper clean

    else
        echo " "
        echo -e "$Error Ошибка: Неизвестный пакетный менеджер!"
        echo " "
        exit 1
    fi
    
    echo " "
    echo -e "$Success Кеш пакетов успешно очищен!"

    sleep 3
    main
}


clean_old_logs() {
    echo " "
    echo -e "$Info Очистка старых журналов..."

    LOG_DIR="/var/log"
    DAYS_TO_KEEP=30

    if [ "$(id -u)" -ne 0 ]; then
        echo " "
        echo -e "$Error Требуются права root! Используйте sudo."
        sleep 2
        main
    fi

    find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS_TO_KEEP -delete -print | while read -r file; do
        echo -e "$Info Удалён: $file"
    done

    if command -v journalctl &>/dev/null; then
        echo " "
        echo -e "$Info Очистка старых журналов..."
        echo " "
        journalctl --vacuum-time="${DAYS_TO_KEEP}d"
    fi

    EXTRA_LOG_DIRS=(
        "/tmp"
        "/var/tmp"
    )

    for dir in "${EXTRA_LOG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f -name "*log*" -mtime +$DAYS_TO_KEEP -delete -print | while read -r file; do
                echo -e "$Info Удалён: $file"
            done
        fi
    done

    echo " "
    echo -e "$Success Очистка журналов завершена!"

    sleep 3
    main
}


temp_files_clean() {
    echo " "
    echo -e "$Info Очистка временных файлов..."
    echo " "
    echo -e "$Info Очистка системных временных файлов..."
    sudo rm -rf /tmp/* /var/tmp/*
    
    echo " "
    echo -e "$Info Очистка пользовательских временных файлов..."
    echo " "
    rm -rf ~/.cache/*
    rm -rf ~/.thumbnails/*
    rm -rf ~/.local/share/Trash/*
    
    echo " "
    echo -e "$Info Очистка старых журналов..."
    echo " "
    sudo journalctl --vacuum-time=1week
    
    if [ -d "/var/log" ]; then
        echo " "
        echo -e "$Info Очистка старых лог-файлов..."
        echo " "
        sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
        sudo find /var/log -type f -name "*.gz" -delete
        sudo find /var/log -type f -name "*.old" -delete
    fi
    
    echo " "
    echo -e "$Success Временные файлы успешно очищены!"

    sleep 3
    main
}


check_dns(){
    echo " "
    echo -e "$Info Проверка DNS..."
    echo " "

    echo -e "$Info Проверка DNS (8.8.8.8)..."

    echo " "

    if ping -c 5 8.8.8.8; then
        echo " "
        echo -e "$Success DNS доступен!"
    else
        echo -e "$Error Не удалось подключиться к DNS!"
    fi

    echo " "
    echo -e "$Success Проверка подключения завершена!"

    sleep 3
    main
}


check_connection() {
    echo " "
    echo -e "$Info Проверка подключения к интернету..."
    echo " "

    echo -e "$Info Проверка DNS (8.8.8.8)..."

    if ping -c 5 8.8.8.8 &> /dev/null; then
        echo -e "$Success DNS доступен!"

    else
        echo -e "$Error Не удалось подключиться к DNS!"
    fi

    echo " "
    echo -e "$Info Проверка доступа в интернет (google.com)..."
    sleep 1

    if ping -c 3 google.com &> /dev/null; then
        echo -e "$Success Интернет доступен!"

    else
        echo -e "$Error Не удалось подключиться к интернету!"
    fi

    echo " "
    echo -e "$Info Проверка подключения к локальному шлюзу..."
    gateway=$(ip route | grep default | awk '{print $3}')

    if [ -n "$gateway" ]; then
        if ping -c 3 "$gateway" &> /dev/null; then
            echo -e "$Success Локальный шлюз ($gateway) доступен!"

        else
            echo -e "$Error Не удалось подключиться к локальному шлюзу ($gateway)!"
        fi

    else
        echo -e "$Error Локальный шлюз не найден!"
    fi

    echo " "
    echo -e "$Success Проверка подключения завершена!"

    sleep 3
    main
}


check_speed() {
    echo " "
    echo -e "$Info Анализ скорости интернета..."
    echo " "

    if ! command -v speedtest-cli &> /dev/null; then
        echo " "
        echo -e "$Error speedtest-cli не установлен. Установка..."
        echo " "
        
        if command -v apt &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
            echo " "
            sudo apt-get update && sudo apt-get install speedtest-cli -y

        elif command -v dnf &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
            echo " "
            sudo dnf install speedtest-cli -y

        elif command -v yum &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен YUM (CentOS/RHEL)"
            echo " "
            sudo yum install speedtest-cli -y

        elif command -v pacman &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Pacman (Arch Linux)"
            echo " "
            sudo pacman -Sy speedtest-cli --noconfirm

        elif command -v zypper &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Zypper (openSUSE)"
            echo " "
            sudo zypper install speedtest-cli -y

        else
            echo " "
            echo -e "$Error Не удалось определить пакетный менеджер!"
            echo -e "$Info Попробуйте установить вручную: python3 -m pip install speedtest-cli"
            sleep 3
            main
            return
        fi

        if ! command -v speedtest-cli &> /dev/null; then
            echo " "
            echo -e "$Error Не удалось установить speedtest-cli!"
            sleep 3
            main
            return
        fi
    fi

    echo -e "$Success Запуск теста скорости (может занять 20-30 секунд)..."
    echo " "

    speed_result=$(speedtest-cli --simple 2>/dev/null)

    if [ -z "$speed_result" ]; then
        echo -e "$Error Не удалось измерить скорость. Проверьте подключение."

    else
        ping=$(echo "$speed_result" | grep "Ping" | awk '{print $2}')
        download=$(echo "$speed_result" | grep "Download" | awk '{print $2}')
        upload=$(echo "$speed_result" | grep "Upload" | awk '{print $2}')

        echo -e "$Success Результаты теста скорости:"
        echo " "
        echo -e "$Info Ping:     $ping ms"
        echo -e "$Info Загрузка: $download Mbit/s"
        echo -e "$Info Отдача:   $upload Mbit/s"
    fi

    echo " "
    echo -e "$Success Анализ завершен!"

    echo -ne "$Info Нажмите ENTER для продолжения... "
    read enter

    main
}


check_security_updates() {
    echo " "
    echo -e "$Info Проверка обновлений безопасности..."

    if command -v apt &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
        echo " "
        security_updates=$(apt-get upgrade --dry-run | grep -i security | wc -l)
        
    elif command -v dnf &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
        echo " "
        security_updates=$(sudo dnf updateinfo list security --available | grep -v "^$" | wc -l)
        
    elif command -v yum &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен YUM (CentOS/RHEL)"
        echo " "
        security_updates=$(sudo yum updateinfo list security | grep -v "^$" | wc -l)
        
    elif command -v pacman &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Pacman (Arch Linux)"
        echo " "
        security_updates=$(pacman -Qu | grep -i security | wc -l)
        
    elif command -v zypper &> /dev/null; then
        echo " "
        echo -e "$Info Обнаружен Zypper (openSUSE)"
        echo " "
        security_updates=$(sudo zypper list-patches --category security | grep -v "^$" | wc -l)
        
    else
        echo " "
        echo -e "$Error Не удалось определить пакетный менеджер!"
        return 1
    fi

    if [ "$security_updates" -gt 0 ]; then
        echo -e "$Success Найдено обновлений безопасности: $security_updates"
        echo " "
        echo -e "$Info Список доступных обновлений безопасности:"
        
        if command -v apt &> /dev/null; then
            apt-get upgrade --dry-run | grep -i security

        elif command -v dnf &> /dev/null; then
            sudo dnf updateinfo list security --available

        elif command -v yum &> /dev/null; then
            sudo yum updateinfo list security

        elif command -v pacman &> /dev/null; then
            pacman -Qu | grep -i security

        elif command -v zypper &> /dev/null; then
            sudo zypper list-patches --category security
        fi
    else
        echo " "
        echo -e "$Success Система актуальна, обновлений безопасности не найдено!"
    fi

    echo " "
    echo -e "$Success Проверка обновлений безопасности завершена!"

    echo -ne "$Info Нажмите ENTER для продолжения... "
    read enter

    main
}


analyze_open_ports() {
    echo " "
    echo -e "$Info Анализ открытых портов..."
    echo " "

    if ! command -v nmap &>/dev/null; then
        echo -e "$Error Nmap не установлен. Установка..."
        echo " "

        if command -v apt &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
            echo " "
            sudo apt install nmap -y
        
        elif command -v dnf &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
            echo " "
            sudo dnf install nmap -y
            
        elif command -v yum &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен YUM (CentOS/RHEL)"
            echo " "
            sudo yum install nmap -y
        
        elif command -v pacman &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Pacman (Arch Linux)"
            echo " "
            sudo pacman -S --noconfirm nmap
        
        elif command -v zypper &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Zypper (openSUSE)"
            echo " "
            sudo zypper install nmap -y
        
        else
            echo " "
            echo -e "$Error Не удалось определить пакетный менеджер!"

            sleep 2
            main
        fi
    fi

    echo -e "$Info Проверка через Nmap..."
    sleep 2
    echo " "
    echo -e "$Success Результаты сканирования портов:"
    sudo nmap -sT -O 127.0.0.1 | grep -E '^[0-9]'
    echo " "

    echo -e "$Success Анализ завершен!"
    echo " "
    echo -e "$Info Рекомендации: закройте неиспользуемые порты для безопасности!"

    echo " "
    echo -e "$Success Проверка открытых портов завершена!"

    echo -ne "$Info Нажмите ENTER для продолжения... "
    read enter

    main
}


check_suspicious_processes() {
    echo " "
    echo -e "$Info Сканирование процессов профессиональными инструментами..."
    echo " "

    if ! command -v chkrootkit &>/dev/null; then
        echo -e "$Error chkrootkit не установлен. Установка..."
        echo " "

        if command -v apt &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
            echo " "
            sudo apt install chkrootkit -y
        
        elif command -v dnf &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
            echo " "
            sudo dnf install chkrootkit -y
            
        elif command -v yum &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен YUM (CentOS/RHEL)"
            echo " "
            sudo yum install chkrootkit -y
        
        elif command -v pacman &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Pacman (Arch Linux)"
            echo " "
            sudo pacman -S --noconfirm chkrootkit

        elif command -v zypper &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Zypper (openSUSE)"
            echo " "
            sudo zypper install chkrootkit -y
        
        else
            echo " "
            echo -e "$Error Не удалось определить пакетный менеджер!"

            sleep 2
            main
        fi
    fi

    if ! command -v lynis &>/dev/null; then
        echo " "
        echo -e "$Error Lynis не установлен. Установка..."

        if command -v apt &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен APT (Debian/Ubuntu)"
            echo " "
            sudo apt install lynis -y
        
        elif command -v dnf &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен DNF (Fedora/RHEL)"
            echo " "
            sudo dnf install lynis -y
            
        elif command -v yum &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен YUM (CentOS/RHEL)"
            echo " "
            sudo yum install lynis -y
        
        elif command -v pacman &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Pacman (Arch Linux)"
            echo " "
            sudo pacman -S --noconfirm lynis
        
        elif command -v zypper &> /dev/null; then
            echo " "
            echo -e "$Info Обнаружен Zypper (openSUSE)"
            echo " "
            sudo zypper install lynis -y
        
        else
            echo " "
            echo -e "$Error Не удалось определить пакетный менеджер!"

            sleep 2
            main
        fi
    fi

    echo " "
    echo -e "$Success Запуск chkrootkit (быстрое сканирование) ..."
    sudo chkrootkit -q | grep -v "not infected" | head -n 15

    sleep 2

    echo " "
    echo -e "$Success Запуск Lynis (проверка процессов) ..."
    echo " "
    sudo lynis audit system --tests "processes" --quick 2>/dev/null | grep -E "(warning|suggestion)" | head -n 10

    if command -v psad &>/dev/null; then
        echo " "
        echo -e "$Success Проверка сетевых угроз (psad) ..."
        echo " "
        sudo psad --Status | grep -A5 "Scan results"
    fi

    echo " "
    echo -e "$Info Для полного сканирования выполните:"
    echo -e "[!] sudo chkrootkit"
    echo -e "[!] sudo lynis audit system"
    echo " "
    echo -e "$Success Быстрое сканирование завершено."

    echo " "
    echo -e "$Success Проверка безопасности системы завершена!"

    echo -ne "$Info Нажмите ENTER для продолжения... "
    read enter

    main
}

# Основное.       

print_banner(){
    clear

    echo -e "\033[1;36m"
    echo """
███████████                    █████      █████   ████                                               
░░███░░░░░███                  ░░███      ░░███   ███░                                                
 ░███    ░███  ██████    █████  ░███████   ░███  ███     ██████   ██████  ████████   ██████  ████████ 
 ░██████████  ░░░░░███  ███░░   ░███░░███  ░███████     ███░░███ ███░░███░░███░░███ ███░░███░░███░░███
 ░███░░░░░███  ███████ ░░█████  ░███ ░███  ░███░░███   ░███████ ░███████  ░███ ░███░███████  ░███ ░░░ 
 ░███    ░███ ███░░███  ░░░░███ ░███ ░███  ░███ ░░███  ░███░░░  ░███░░░   ░███ ░███░███░░░   ░███     
 ███████████ ░░████████ ██████  ████ █████ █████ ░░████░░██████ ░░██████  ░███████ ░░██████  █████    
░░░░░░░░░░░   ░░░░░░░░ ░░░░░░  ░░░░ ░░░░░ ░░░░░   ░░░░  ░░░░░░   ░░░░░░   ░███░░░   ░░░░░░  ░░░░░     
                                                                          ░███                        
                                                                          █████                       
                                                                         ░░░░░          
    ╔═════════════════════════════════════════════════════╗                         
    ║ Github: https://github.com/DenisPythoneer           ║
    ║ version: 1.0                                        ║
    ║ Created: DenisPythoneer                             ║
    ╚═════════════════════════════════════════════════════╝
    """
    echo -e "\033[0m"
}


user_input(){
    echo -e """
\033[1;36m[1]\e[0m Обновление списка пакетов                       \033[1;36m[7]\e[0m Проверка DNS
\033[1;36m[2]\e[0m Обновление всех установленных пакетов           \033[1;36m[8]\e[0m Проверка подключения
\033[1;36m[3]\e[0m Автоматическое удаление старых зависимостей     \033[1;36m[9]\e[0m Анализ скорости интернета

\033[1;36m[4]\e[0m Удаление кеша пакетов                           \033[1;36m[10]\e[0m Проверка обновлений безопасности
\033[1;36m[5]\e[0m Удаление старых журналов                        \033[1;36m[11]\e[0m Анализ открытых портов
\033[1;36m[6]\e[0m Очистка временных файлов                        \033[1;36m[12]\e[0m Проверка подозрительных процессов
            

\e[1;31m[0] Выход\e[0m 
    """

    echo -ne "\033[1;33m[!] Введите пункт меню: \033[0m"
    read choice

    case $choice in
        0)
            exit_0
            ;;
        1)
            package_update
            ;;
        2)
            package_upgrade
            ;;
        3)
            clean_dependencies
            ;;
        4)
            package_cache_clean
            ;;
        5)
            clean_old_logs
            ;;
        6)
            temp_files_clean
            ;;
        7)
            check_dns
            ;;
        8)
            check_connection
            ;;
        9)
            check_speed
            ;;
        10)
            check_security_updates
            ;;
        11)
            analyze_open_ports
            ;;
        12)
            check_suspicious_processes
            ;;
        *)
            echo " "
            echo -e "$Error Выберите конкретный пункт меню!"

            sleep 2
            main
            ;;
    esac
}


main(){
    trap ctrl_c_handler SIGINT

    print_banner
    user_input
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then # if __name__ == "__main__":
    main
fi