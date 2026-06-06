package br.com.estudo.almoxarifado.domain;

public interface MaterialFactory {
    Material criar(String codigo, String nome, int saldoInicial);
}
