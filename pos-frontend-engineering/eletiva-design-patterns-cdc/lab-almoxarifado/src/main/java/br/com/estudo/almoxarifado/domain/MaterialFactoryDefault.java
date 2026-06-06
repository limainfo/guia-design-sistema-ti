package br.com.estudo.almoxarifado.domain;

public class MaterialFactoryDefault implements MaterialFactory {
    @Override
    public Material criar(String codigo, String nome, int saldoInicial) {
        return new MaterialImpl(codigo, nome, saldoInicial);
    }
}
