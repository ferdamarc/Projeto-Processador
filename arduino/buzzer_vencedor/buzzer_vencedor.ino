/*
 * buzzer_vencedor.ino
 *
 * Recebe, via UART (9600 8N1), 1 byte enviado pelo FPGA (instrucao uart_send)
 * e aciona um buzzer indicando o resultado do jogo da velha:
 *
 *   1 -> jogador 1 venceu  (melodia ascendente)
 *   2 -> jogador 2 venceu  (melodia descendente)
 *   3 -> empate            (dois beeps curtos)
 *
 * Ao TERMINAR de tocar, o Arduino envia de volta 1 byte de ACK (0xFF =
 * "fim de som") pela UART. O FPGA fica em busy-wait (uart_rx_available /
 * uart_receive) ate receber esse ACK e so entao volta a computar.
 *
 * ---------------------------------------------------------------------------
 * LIGACAO (IMPORTANTE):
 *   FPGA uart_tx_pin (GPIO[0], 3,3 V) ----> Arduino pino 10 (RX do SoftwareSerial)
 *   Arduino pino 11 (TX, 5 V) --[divisor]--> FPGA uart_rx_pin (GPIO[1], 3,3 V)
 *   GND do FPGA <---------------------> GND do Arduino   (terra comum obrigatorio)
 *   Buzzer:  pino 8 do Arduino ----> (+) buzzer ;  (-) buzzer ----> GND
 *
 * Sentido FPGA->Arduino (pino 10): o FPGA transmite em 3,3 V e o Arduino Uno
 * (5 V) le isso como nivel ALTO sem problema (Vih ~3,0 V) -> NAO precisa de
 * level shifter.
 *
 * Sentido Arduino->FPGA (pino 11 -> uart_rx_pin): a saida TX do Arduino e 5 V e
 * o pino do FPGA e 3,3 V -> OBRIGATORIO divisor resistivo (ex.: 1k em serie +
 * 2k para GND, lendo no meio) ou level shifter, senao o pino do FPGA pode ser
 * danificado.
 *
 * Usa-se SoftwareSerial (pinos 10/11) para manter a Serial USB (pinos 0/1)
 * livre para depuracao no monitor serial.
 * ---------------------------------------------------------------------------
 */

#include <SoftwareSerial.h>

const uint8_t PINO_RX     = 10;   // recebe do FPGA (uart_tx_pin)
const uint8_t PINO_TX     = 11;   // envia o ACK ao FPGA (-> divisor -> uart_rx_pin)
const uint8_t PINO_BUZZER = 8;    // buzzer

const uint8_t ACK_FIM_SOM = 0xFF; // byte enviado ao FPGA quando o som termina

SoftwareSerial fpgaSerial(PINO_RX, PINO_TX);

void setup() {
  pinMode(PINO_BUZZER, OUTPUT);
  Serial.begin(9600);        // monitor serial (depuracao via USB)
  fpgaSerial.begin(9600);    // mesma baud do modulo uart_tx no FPGA
  Serial.println("Aguardando resultado do FPGA...");
}

void melodiaJogador1() {      // ascendente
  tone(PINO_BUZZER, 523, 150); delay(180);
  tone(PINO_BUZZER, 659, 150); delay(180);
  tone(PINO_BUZZER, 784, 300); delay(320);
  noTone(PINO_BUZZER);
}

void melodiaJogador2() {      // descendente
  tone(PINO_BUZZER, 784, 150); delay(180);
  tone(PINO_BUZZER, 659, 150); delay(180);
  tone(PINO_BUZZER, 523, 300); delay(320);
  noTone(PINO_BUZZER);
}

void melodiaEmpate() {        // dois beeps curtos
  tone(PINO_BUZZER, 440, 120); delay(160);
  tone(PINO_BUZZER, 440, 120); delay(160);
  noTone(PINO_BUZZER);
}

void loop() {
  if (fpgaSerial.available() > 0) {
    int b = fpgaSerial.read();
    Serial.print("Recebido do FPGA: ");
    Serial.println(b);

    switch (b) {
      case 1: melodiaJogador1(); break;
      case 2: melodiaJogador2(); break;
      case 3: melodiaEmpate();   break;
      default: /* byte desconhecido: ignora */ break;
    }

    // Avisa o FPGA que o som terminou para ele voltar a computar.
    fpgaSerial.write(ACK_FIM_SOM);
    Serial.println("ACK fim de som enviado ao FPGA");
  }
}
