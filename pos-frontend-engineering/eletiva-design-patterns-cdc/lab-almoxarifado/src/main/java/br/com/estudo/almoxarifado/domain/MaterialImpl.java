package br.com.estudo.almoxarifado.domain;

public final class MaterialImpl implements Material {
    private final String codigo;
    private final String nome;
    private int saldo;

    MaterialImpl(String codigo, String nome, int saldoInicial) {
        if (codigo == null || codigo.isBlank()) {
            throw new IllegalArgumentException("Código é obrigatório");
        }
        if (nome == null || nome.isBlank()) {
            throw new IllegalArgumentException("Nome é obrigatório");
        }
        if (saldoInicial < 0) {
            throw new IllegalArgumentException("Saldo inicial não pode ser negativo");
        }
        this.codigo = codigo;
        this.nome = nome;
        this.saldo = saldoInicial;
    }

    public void entrada(int quantidade) {
        validarQuantidade(quantidade);
        saldo += quantidade;
    }

    public void saida(int quantidade) {
        validarQuantidade(quantidade);
        if (saldo < quantidade) {
            throw new IllegalStateException("Saldo insuficiente");
        }
        saldo -= quantidade;
    }

    private void validarQuantidade(int quantidade) {
        if (quantidade <= 0) {
            throw new IllegalArgumentException("Quantidade deve ser positiva");
        }
    }

    @Override
    public String getCodigo() {
        return codigo;
    }

    @Override
    public String getNome() {
        return nome;
    }

    @Override
    public int getSaldo() {
        return saldo;
    }
}
