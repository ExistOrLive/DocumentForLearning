global _start   ; 定义入口函数
 
section .data
  query_string        :  db    "Enter a character:  "
  query_string_len    :  equ   $ - query_string
  out_string          :  db    "You have input:  "
  out_string_len      :  equ   $ - out_string
 
section .bss
  in_char:			resw 4
 
section .text
 
_start:
  mov rax, 0x2000004         ; syscall需要用到的参数，表示write
  mov rdi, 1                 ; 表示stdout
  mov rsi, query_string      ; syscall调用回到rsi来获取字符
  mov rdx, query_string_len  ; 并到rdx获取长度
  syscall
 
  ; 读取字符
  mov rax, 0x2000003         ; syscall需要用到的参数，表示read
  mov rdi, 0                 ; 表示stdin
  mov rsi, in_char           ; 字符存储位置，在.bbs段
  mov rdx, 2                 ; 从内核缓存获取两个字节,一个给字符一个给回车
  syscall
 
  ; 打印输入的值
  mov rax, 0x2000004
  mov rdi, 1
  mov rsi, out_string
  mov rdx, out_string_len
  syscall
 
  mov rax, 0x2000004
  mov rdi, 1
  mov rsi, in_char
  mov rdx, 2                 ; 这里两个字节，因为第二个是回车
  syscall
 
  ; 退出syscall
  mov rax, 0x2000001         ; syscall需要用到的参数，表示退出syscall
  mov rdi, 0
  syscall