package br.com.estudo.almoxarifado.application;

import br.com.estudo.almoxarifado.domain.Material;

public interface EstoqueService {
    void cadastrarMaterial(Material material);
    int consultarSaldo(String codigo);
    void registrarEntrada(String codigo, int quantidade);
    void registrarSaida(String codigo, int quantidade);
}
