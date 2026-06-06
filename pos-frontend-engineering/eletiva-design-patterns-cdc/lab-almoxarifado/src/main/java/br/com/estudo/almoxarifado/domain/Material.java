package br.com.estudo.almoxarifado.domain;

public interface Material {
    String getCodigo();
    String getNome();
    int getSaldo();
    void entrada(int quantidade);
    void saida(int quantidade);
}
