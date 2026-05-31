/*
 * uart_rx_test.ino
 *
 * Sketch de teste ISOLADO do caminho de RECEPCAO (RX) do FPGA.
 * O Arduino envia, via UART (9600 8N1), um byte ciclico (1, 2, 3, 1, 2, 3, ...)
 * a cada ~1 segundo para o pino RX do FPGA (uart_rx_pin = GPIO[1]).
 *
 * No FPGA, rode tests/fpga/teste_uart_rx.cm: ele faz uart_receive() e mostra o
 * byte recebido na saida (LEDs / 7-seg via output). Assim da para validar o RX
 * sozinho, sem depender do TX.
 *
 * ---------------------------------------------------------------------------
 * LIGACAO (IMPORTANTE):
 *   Arduino pino 11 (TX, 5 V) --[divisor]--> FPGA uart_rx_pin (GPIO[1], 3,3 V)
 *   GND do Arduino <-----------------------> GND do FPGA  (terra comum obrigatorio)
 *
 * A saida TX do Arduino e 5 V e o pino do FPGA e 3,3 V -> OBRIGATORIO usar
 * divisor resistivo (ex.: 1k em serie + 2k para GND, lendo a tensao no meio =>
 * ~3,3 V) ou um level shifter. Ligar 5 V direto pode danificar o pino do FPGA.
 *
 * Usa-se SoftwareSerial (pino 11 = TX) para manter a Serial USB livre para o
 * monitor serial.
 * ---------------------------------------------------------------------------
 */

#include <SoftwareSerial.h>

const uint8_t PINO_RX = 10;   // nao usado neste teste (so TX)
const uint8_t PINO_TX = 11;   // envia para o FPGA (-> divisor -> uart_rx_pin)

SoftwareSerial fpgaSerial(PINO_RX, PINO_TX);

uint8_t valor = 1;

void setup() {
  Serial.begin(9600);        // monitor serial (depuracao via USB)
  fpgaSerial.begin(9600);    // mesma baud do modulo uart_rx no FPGA
  Serial.println("Enviando bytes de teste ao FPGA (1,2,3,...)");
}

void loop() {
  fpgaSerial.write(valor);
  Serial.print("Enviado ao FPGA: ");
  Serial.println(valor);

  valor = valor + 1;
  if (valor > 3) {
    valor = 1;
  }

  delay(1000);
}
