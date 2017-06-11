/* -------------------------------------------------------------------
 *            Arquivo: compilaodr.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e vaiáveis globais do compilador
 *
 * ------------------------------------------------------------------- */

#ifndef COMPILADOR_H
#define COMPILADOR_H
#define TAM_TOKEN 16

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end, simb_igual, simb_mais,
  simb_menos, simb_asteristico, simb_barra, simb_mod, simb_div, simb_and,
  simb_or, simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses, simb_do,
  simb_while, simb_if, simb_else, simb_function, simb_procedure, simb_integer,
  simb_ident, simb_numero, simb_label, simb_goto
} simbolos;

/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nl;

simbolos simbolo, relacao;
char token[TAM_TOKEN];
void gera_codigo (char* rot, char* comando);
int imprime_erro ( char* erro );

#endif
