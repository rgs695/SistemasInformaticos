# Como ver el inodo de un archivo: (aunque lo hayan borrado)

Primero obtuvimos el nº de inodo del dir en el que esta elarchivo.
```bash
[ (Ej2) root@examen /home ] ls
user1  user2  user3
[ (Ej2) root@examen /home ] ls -i
2 user1  2 user2  2 user3
```

Sabemos que tiene el inodo 2 asi que con debugfs buscamos a que bloque se corresponde.
```bash
[ (Ej2) root@examen /home ] debugfs /dev/sdb1
debugfs 1.46.2 (28-Feb-2021)
debugfs:  stat <2>

Inode: 2   Type: directory    Mode:  0700   Flags: 0x80000
Generation: 0    Version: 0x0000002a
User:  1001   Group:  1001   Size: 1024
File ACL: 0
Links: 6   Blockcount: 2
Fragment:  Address: 0    Number: 0    Size: 0
ctime: 0x67ddbebb -- Fri Mar 21 20:32:11 2025
atime: 0x67ddbebe -- Fri Mar 21 20:32:14 2025
mtime: 0x67ddbebb -- Fri Mar 21 20:32:11 2025
Inode checksum: 0x0000dfff
EXTENTS:
(0):1210 # ESTE ES EL NUMERO DEL BLOQUE
````
Ahora examinamos el contenido del bloque.

```bash
[ (Ej2) root@examen /home/user1 ] debugfs /dev/sdb1
debugfs 1.46.2 (28-Feb-2021)
debugfs:  block_dump 1210
0000  0200 0000 0c00 0102 2e00 0000 0200 0000  ................
0020  0c00 0202 2e2e 0000 0b00 0000 1400 0a02  ................
0040  6c6f 7374 2b66 6f75 6e64 0000 0c00 0000  lost+found......
0060  1400 0c01 2e62 6173 685f 6c6f 676f 7574  .....bash_logout
0100  0d00 0000 1000 0701 2e62 6173 6872 6300  .........bashrc.
0120  0e00 0000 1000 0801 2e70 726f 6669 6c65  .........profile
0140  8107 0000 1400 0a02 446f 6375 6d65 6e74  ........Document
0160  6f73 0000 8207 0000 1000 0602 4d75 7369  os..........Musi
0200  6361 0000 8307 0000 1400 0a02 4573 6372  ca..........Escr
0220  6974 6f72 696f 0000 1300 0000 2400 0d01  itorio......$...
0240  2e62 6173 685f 6869 7374 6f72 7977 706c  .bash_historywpl
0260  6573 612e 7478 742e 7377 7000 1100 0000  esa.txt.swp.....
0300  2000 1601 4c69 7465 7261 7475 7261 5f49   ...Literatura_I
0320  6e67 6c65 7361 2e74 7874 742e 1600 0000  nglesa.txtt.....
0340  1000 0801 2e76 696d 696e 666f 1400 0000  .....viminfo....
0360  0803 0901 696d 6167 652e 706e 6774 742e  ....image.pngtt.
0400  1600 0000 f402 0c01 2e76 696d 696e 666f  .........viminfo
0420  2e74 6d70 0000 0000 0000 0000 0000 0000  .tmp............
0440  0000 0000 0000 0000 0000 0000 0000 0000  ................
*
1760  0000 0000 0000 0000 0c00 00de aa60 c1a9  .............`..
```

Nos fijaremos en estas lineas:
- 0340  1000 0801 2e76 696d 696e 666f 1400 0000  .....viminfo....
- 0360  0803 0901 696d 6167 652e 706e 6774 742e  ....image.pngtt.

---

Antes del nombre "image.png" se guarda el num de inodo y otra cosa.
Avanzamos hacia atrás 8 digitos y los 6 siguientes son el num de inodo del reves.
- 00  0803 0901 (campo previo)
- 1400 00 (NUMERO DE INODO), que puesto bien (esta en lit endian) es 000014 QUE EN DECIMAL ES 20.

- NUMERO DE INODO = 20

