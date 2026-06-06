package br.com.estudo.almoxarifado.application;

import br.com.estudo.almoxarifado.domain.Material;

public interface EstoqueGateway {
    void enviarAtualizacao(Material material);
}
