Aquí tienes los comandos resumidos para reemplazar cat con un script personalizado para un usuario específico:

# 1. Crear directorio para comandos personalizados
mkdir -p /home/usuario/mis_comandos

# 2. Crear el script personalizado
echo -e '#!/bin/bash\necho "Ejecutando script personalizado"\n/bin/cat "$@"' > /home/usuario/mis_comandos/cat

# 3. Dar permisos de ejecución
chmod +x /home/usuario/mis_comandos/cat

# 4. Modificar el PATH en ~/.bashrc
echo 'export PATH=/home/usuario/mis_comandos:$PATH' >> /home/usuario/.bashrc

# 5. Aplicar cambios en la sesión
source /home/usuario/.bashrc

# 6. Verificar que el script se ejecuta en lugar del cat original
which cat
cat archivo.txt
