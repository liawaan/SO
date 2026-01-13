# ALGORITMA SIMPLES OS

## Daftar Isi

1. [Boot Loader (boot.asm)](#boot-loader)
2. [Kernel (kernel.asm)](#kernel)
3. [Fungsi-Fungsi Utama](#fungsi-fungsi-utama)

---

## BOOT LOADER (boot.asm)

### Algoritma Utama Bootloader

```
MULAI Program Bootloader
├─ [1] Inisialisasi Segmen
│   ├─ Set DS (Data Segment) = 0
│   ├─ Set ES (Extra Segment) = 0
│   ├─ Set SS (Stack Segment) = 0
│   └─ Set SP (Stack Pointer) = 0x7C00
│
├─ [2] Bersihkan Layar
│   └─ Panggil fungsi clear_screen()
│
├─ [3] Tampilkan Pesan Selamat Datang
│   ├─ Load address pesan ke SI
│   └─ Panggil fungsi print_string()
│
├─ [4] Muat Kernel dari Disk
│   ├─ Tampilkan pesan "Loading kernel..."
│   ├─ Set parameter pembacaan disk:
│   │   ├─ AH = 0x02 (fungsi read sector)
│   │   ├─ AL = 10 (jumlah sector yang dibaca)
│   │   ├─ CH = 0 (cylinder 0)
│   │   ├─ CL = 2 (mulai dari sector 2)
│   │   ├─ DH = 0 (head 0)
│   │   └─ BX = 0x1000 (alamat memori tujuan)
│   ├─ Panggil BIOS interrupt 0x13
│   └─ JIKA error:
│       ├─ Tampilkan pesan error
│       └─ Hentikan sistem (infinite loop)
│
├─ [5] Tampilkan Pesan "OK"
│
└─ [6] Lompat ke Kernel
    └─ Jump ke alamat 0x1000 (lokasi kernel)
SELESAI
```

### Pseudocode Bootloader

```
Procedure BOOTLOADER_MAIN:
    // Fase 1: Setup Lingkungan
    DS ← 0
    ES ← 0
    SS ← 0
    SP ← 0x7C00

    // Fase 2: Persiapan Tampilan
    CALL clear_screen()
    CALL print_string("SimpleOS v1.0")

    // Fase 3: Load Kernel
    CALL print_string("Loading kernel...")

    result ← BIOS_READ_DISK(
        function: READ_SECTORS,
        sectors: 10,
        cylinder: 0,
        sector_start: 2,
        head: 0,
        destination: 0x1000
    )

    IF result == ERROR THEN
        CALL print_string("ERROR!")
        HALT_SYSTEM()
    ELSE
        CALL print_string("OK")
        JUMP_TO(0x1000)  // Eksekusi kernel
    END IF
End Procedure
```

### Algoritma Fungsi Pendukung Bootloader

#### 1. Fungsi clear_screen()

```
Procedure clear_screen():
    AH ← 0x00  // Set video mode
    AL ← 0x03  // Mode 3 (80x25 text)
    CALL BIOS_INTERRUPT(0x10)
    RETURN
End Procedure
```

#### 2. Fungsi print_string()

```
Procedure print_string(string_address):
    AH ← 0x0E  // Teletype output

    WHILE TRUE DO
        character ← LOAD_BYTE_FROM(string_address)

        IF character == 0 THEN
            BREAK  // Null terminator
        END IF

        AL ← character
        CALL BIOS_INTERRUPT(0x10)
        string_address ← string_address + 1
    END WHILE

    RETURN
End Procedure
```

---

## KERNEL (kernel.asm)

### Algoritma Utama Kernel

```
MULAI Program Kernel
├─ [1] Inisialisasi Kernel
│   ├─ Set DS = 0
│   ├─ Set ES = 0
│   ├─ Bersihkan layar
│   └─ Tampilkan pesan "Kernel loaded"
│
├─ [2] Tampilkan Menu Utama
│   └─ Panggil show_menu()
│
└─ [3] Loop Utama (Main Loop)
    ├─ Tunggu input keyboard
    │
    ├─ JIKA input = '1':
    │   └─ Panggil cmd_system_info()
    │
    ├─ JIKA input = '2':
    │   └─ Panggil cmd_memory_info()
    │
    ├─ JIKA input = '3':
    │   └─ Panggil cmd_calculator()
    │
    ├─ JIKA input = '4':
    │   └─ Panggil cmd_text_editor()
    │
    ├─ JIKA input = '5':
    │   └─ Panggil cmd_shutdown()
    │
    └─ Ulangi loop
SELESAI
```

### Pseudocode Kernel Utama

```
Procedure KERNEL_MAIN:
    // Inisialisasi
    DS ← 0
    ES ← 0

    CALL clear_screen()
    CALL print_string("Kernel loaded successfully!")
    CALL show_menu()

    // Loop utama
    WHILE TRUE DO
        key ← WAIT_FOR_KEYPRESS()

        CASE key OF
            '1': CALL cmd_system_info()
            '2': CALL cmd_memory_info()
            '3': CALL cmd_calculator()
            '4': CALL cmd_text_editor()
            '5': CALL cmd_shutdown()
            DEFAULT: CONTINUE
        END CASE
    END WHILE
End Procedure
```

---

## FUNGSI-FUNGSI UTAMA

### 1. System Information (cmd_system_info)

```
ALGORITMA cmd_system_info:
1. Bersihkan layar
2. Tampilkan header "System Information"
3. Tampilkan info CPU:
   ├─ Deteksi CPU menggunakan CPUID
   ├─ Tampilkan vendor CPU
   └─ Tampilkan mode (Real Mode 16-bit)
4. Tunggu input user
5. Kembali ke menu utama

Pseudocode:
Procedure cmd_system_info():
    CALL clear_screen()
    PRINT("===== System Information =====")

    // Deteksi CPU
    PRINT("CPU: ")
    cpu_info ← CPUID_INSTRUCTION()
    PRINT("x86 Compatible")
    PRINT("Mode: Real Mode 16-bit")

    WAIT_FOR_KEY()
    CALL clear_screen()
    CALL show_menu()
    RETURN
End Procedure
```

### 2. Memory Information (cmd_memory_info)

```
ALGORITMA cmd_memory_info:
1. Bersihkan layar
2. Tampilkan header "Memory Information"
3. Dapatkan ukuran memori:
   ├─ Panggil BIOS interrupt 0x12
   ├─ Hasil dalam AX (ukuran dalam KB)
   └─ Tampilkan hasilnya
4. Tunggu input user
5. Kembali ke menu utama

Pseudocode:
Procedure cmd_memory_info():
    CALL clear_screen()
    PRINT("===== Memory Information =====")
    PRINT("Base Memory: ")

    memory_kb ← GET_MEMORY_SIZE()  // BIOS INT 0x12
    CALL print_number(memory_kb)
    PRINT(" KB")

    WAIT_FOR_KEY()
    CALL clear_screen()
    CALL show_menu()
    RETURN
End Procedure
```

### 3. Calculator (cmd_calculator)

```
ALGORITMA cmd_calculator:
1. Bersihkan layar
2. Tampilkan header "Calculator"
3. Input angka pertama:
   ├─ Tampilkan prompt
   ├─ Baca input menggunakan input_number()
   └─ Simpan ke num1
4. Input operator:
   ├─ Tampilkan prompt
   ├─ Baca karakter (+, -, *, /)
   └─ Simpan operator
5. Input angka kedua:
   ├─ Tampilkan prompt
   ├─ Baca input menggunakan input_number()
   └─ Simpan ke num2
6. Hitung hasil:
   ├─ Load num1 ke AX
   ├─ Load num2 ke BX
   ├─ JIKA operator = '+': AX ← AX + BX
   ├─ JIKA operator = '-': AX ← AX - BX
   ├─ JIKA operator = '*': AX ← AX * BX
   └─ JIKA operator = '/': AX ← AX / BX
7. Tampilkan hasil
8. Tunggu input user
9. Kembali ke menu utama

Pseudocode:
Procedure cmd_calculator():
    CALL clear_screen()
    PRINT("===== Calculator =====")

    // Input
    PRINT("First number: ")
    num1 ← CALL input_number()

    PRINT("Operator (+,-,*,/): ")
    operator ← WAIT_FOR_KEY()
    PRINT(operator)

    PRINT("Second number: ")
    num2 ← CALL input_number()

    // Hitung
    PRINT("Result: ")
    result ← 0

    CASE operator OF
        '+': result ← num1 + num2
        '-': result ← num1 - num2
        '*': result ← num1 * num2
        '/': result ← num1 / num2
    END CASE

    CALL print_number(result)

    WAIT_FOR_KEY()
    CALL clear_screen()
    CALL show_menu()
    RETURN
End Procedure
```

### 4. Text Editor (cmd_text_editor)

```
ALGORITMA cmd_text_editor:
1. Bersihkan layar
2. Tampilkan header "Text Editor"
3. Tampilkan instruksi (ESC untuk keluar)
4. Inisialisasi buffer teks
5. Loop input:
   ├─ Tunggu input karakter
   ├─ JIKA karakter = ESC:
   │   └─ Keluar dari loop
   ├─ JIKA karakter = BACKSPACE:
   │   ├─ Hapus karakter terakhir dari buffer
   │   └─ Hapus karakter di layar
   ├─ JIKA tidak:
   │   ├─ Tampilkan karakter di layar
   │   └─ Simpan di buffer
   └─ Ulangi loop
6. Kembali ke menu utama

Pseudocode:
Procedure cmd_text_editor():
    CALL clear_screen()
    PRINT("===== Text Editor =====")
    PRINT("Type text (ESC to exit)")

    buffer_pointer ← START_OF_TEXT_BUFFER

    WHILE TRUE DO
        key ← WAIT_FOR_KEY()

        IF key == ESC THEN
            BREAK
        ELSE IF key == BACKSPACE THEN
            IF buffer_pointer > START_OF_TEXT_BUFFER THEN
                buffer_pointer ← buffer_pointer - 1
                MEMORY[buffer_pointer] ← 0

                // Hapus di layar
                PRINT(BACKSPACE)
                PRINT(SPACE)
                PRINT(BACKSPACE)
            END IF
        ELSE
            // Echo dan simpan
            PRINT(key)
            MEMORY[buffer_pointer] ← key
            buffer_pointer ← buffer_pointer + 1
        END IF
    END WHILE

    CALL clear_screen()
    CALL show_menu()
    RETURN
End Procedure
```

### 5. Shutdown (cmd_shutdown)

```
ALGORITMA cmd_shutdown:
1. Bersihkan layar
2. Tampilkan pesan "Shutting down..."
3. Coba APM shutdown:
   ├─ Connect ke APM (INT 0x15, AX=0x5301)
   └─ Set power state off (INT 0x15, AX=0x5307)
4. JIKA APM gagal:
   ├─ Disable interrupts (CLI)
   └─ Halt CPU (HLT)

Pseudocode:
Procedure cmd_shutdown():
    CALL clear_screen()
    PRINT("Shutting down...")
    PRINT("You can now close VirtualBox")

    // Coba APM shutdown
    result ← APM_CONNECT()
    IF result == SUCCESS THEN
        APM_SET_POWER_STATE(OFF)
    END IF

    // Fallback: halt
    DISABLE_INTERRUPTS()
    HALT_CPU()
End Procedure
```

---

## FUNGSI-FUNGSI UTILITY

### 1. print_number()

```
ALGORITMA print_number(number):
1. Inisialisasi:
   ├─ counter = 0
   └─ base = 10
2. Konversi angka ke digit:
   WHILE number > 0 DO
       ├─ digit = number MOD 10
       ├─ PUSH digit ke stack
       ├─ counter = counter + 1
       └─ number = number / 10
   END WHILE
3. Cetak digit:
   WHILE counter > 0 DO
       ├─ POP digit dari stack
       ├─ Konversi ke ASCII (digit + '0')
       ├─ Cetak karakter
       └─ counter = counter - 1
   END WHILE

Pseudocode:
Procedure print_number(number):
    counter ← 0
    base ← 10

    // Ekstrak digit (dalam urutan terbalik)
    WHILE number > 0 DO
        digit ← number MOD base
        PUSH digit
        counter ← counter + 1
        number ← number / base
    END WHILE

    // Cetak digit (urutan benar)
    WHILE counter > 0 DO
        digit ← POP
        ascii_char ← digit + ASCII_OFFSET_0
        PRINT_CHAR(ascii_char)
        counter ← counter - 1
    END WHILE

    RETURN
End Procedure
```

### 2. input_number()

```
ALGORITMA input_number():
1. Inisialisasi:
   ├─ result = 0
   └─ base = 10
2. Loop input:
   WHILE TRUE DO
       ├─ Baca karakter
       ├─ JIKA karakter = ENTER:
       │   └─ BREAK
       ├─ JIKA karakter bukan digit (0-9):
       │   └─ CONTINUE
       ├─ Echo karakter ke layar
       ├─ Konversi ASCII ke digit (char - '0')
       ├─ result = (result * 10) + digit
       └─ Ulangi
   END WHILE
3. Cetak newline
4. RETURN result

Pseudocode:
Procedure input_number():
    result ← 0
    base ← 10

    WHILE TRUE DO
        char ← WAIT_FOR_KEY()

        IF char == ENTER THEN
            BREAK
        END IF

        IF char < '0' OR char > '9' THEN
            CONTINUE  // Abaikan input non-digit
        END IF

        // Echo
        PRINT_CHAR(char)

        // Konversi dan akumulasi
        digit ← char - ASCII_OFFSET_0
        result ← (result * base) + digit
    END WHILE

    // Newline
    PRINT_CHAR(CARRIAGE_RETURN)
    PRINT_CHAR(LINE_FEED)

    RETURN result
End Procedure
```

### 3. show_menu()

```
ALGORITMA show_menu():
1. Cetak border atas
2. Cetak setiap pilihan menu:
   ├─ "1. System Information"
   ├─ "2. Memory Information"
   ├─ "3. Calculator"
   ├─ "4. Text Editor"
   └─ "5. Shutdown"
3. Cetak prompt "Choose: "

Pseudocode:
Procedure show_menu():
    PRINT("===== SimpleOS Menu =====")
    PRINT("1. System Information")
    PRINT("2. Memory Information")
    PRINT("3. Calculator")
    PRINT("4. Text Editor")
    PRINT("5. Shutdown")
    PRINT("")
    PRINT("Choose: ")
    RETURN
End Procedure
```

---

## STRUKTUR DATA

### Memory Layout

```
0x0000 - 0x03FF : Interrupt Vector Table
0x0400 - 0x04FF : BIOS Data Area
0x0500 - 0x7BFF : Free memory
0x7C00 - 0x7DFF : Bootloader (512 bytes)
0x7E00 - 0x0FFF : Free memory
0x1000 - 0x23FF : Kernel (10 sectors = 5120 bytes)
0x2400 - 0x9FFF : Free memory untuk user
```

### Data Variables

```
num1        : WORD (2 bytes) - Angka pertama calculator
num2        : WORD (2 bytes) - Angka kedua calculator
operator    : BYTE (1 byte)  - Operator calculator (+,-,*,/)
text_buffer : ARRAY[1024]    - Buffer untuk text editor
```

---

## DIAGRAM ALUR EKSEKUSI

```
┌─────────────────┐
│   BIOS Power    │
│      On         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  BIOS Loads     │
│  Boot Sector    │
│  (0x7C00)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  BOOTLOADER     │
│  - Init Segments│
│  - Clear Screen │
│  - Show Message │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Load Kernel    │
│  from Disk      │
│  (Sector 2-11)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Jump to Kernel │
│  (0x1000)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  KERNEL START   │
│  - Init         │
│  - Show Menu    │
└────────┬────────┘
         │
         ▼
    ┌────┴─────┐
    │Main Loop │◄──────┐
    └────┬─────┘       │
         │             │
         ▼             │
    ┌────────┐         │
    │ Input  │         │
    └────┬───┘         │
         │             │
    ┌────┴────┐        │
    │ Switch  │        │
    └─┬──┬──┬─┘        │
      │  │  │          │
      1  2  3  4  5    │
      │  │  │  │  │    │
      ▼  ▼  ▼  ▼  ▼    │
     ┌───────────┐     │
     │  Execute  │     │
     │  Command  │─────┘
     └───────────┘
```

---

## KOMPLEKSITAS & ANALISIS

### Kompleksitas Waktu

| Fungsi         | Kompleksitas | Keterangan               |
| -------------- | ------------ | ------------------------ |
| print_string() | O(n)         | n = panjang string       |
| print_number() | O(log n)     | n = nilai angka          |
| input_number() | O(m)         | m = jumlah digit input   |
| clear_screen() | O(1)         | Panggilan BIOS           |
| calculator     | O(1)         | Operasi aritmatika dasar |
| text_editor    | O(k)         | k = jumlah karakter      |

### Kompleksitas Ruang

| Komponen    | Ukuran     | Lokasi              |
| ----------- | ---------- | ------------------- |
| Bootloader  | 512 bytes  | 0x7C00              |
| Kernel      | 5120 bytes | 0x1000              |
| Text Buffer | 1024 bytes | Variable            |
| Stack       | ~512 bytes | 0x7C00 (grows down) |

---

## CARA KOMPILASI & MENJALANKAN

### Kompilasi:

```bash
# Compile bootloader
nasm -f bin boot.asm -o boot.bin

# Compile kernel
nasm -f bin kernel.asm -o kernel.bin

# Gabungkan keduanya
cat boot.bin kernel.bin > os.img
# Atau di Windows:
copy /b boot.bin+kernel.bin os.img
```

### Menjalankan di VirtualBox:

```bash
# Buat virtual disk
VBoxManage convertfromraw os.img os.vdi --format VDI

# Atau jalankan dengan QEMU
qemu-system-x86_64 -drive format=raw,file=os.img
```

---

## CATATAN PENTING

1. **Mode Real**: OS berjalan dalam Real Mode 16-bit (bukan Protected Mode)
2. **Memory Limit**: Hanya dapat mengakses 1 MB RAM pertama
3. **BIOS Dependency**: Bergantung pada BIOS interrupts (INT 0x10, 0x13, 0x15, 0x16)
4. **Single Task**: Tidak ada multitasking, single-threaded execution
5. **No File System**: Tidak ada sistem file, kernel dimuat langsung dari sector

---

**Dibuat untuk: Project Akhir OOP - SimpleOS**
**Tanggal: 13 Januari 2026**
