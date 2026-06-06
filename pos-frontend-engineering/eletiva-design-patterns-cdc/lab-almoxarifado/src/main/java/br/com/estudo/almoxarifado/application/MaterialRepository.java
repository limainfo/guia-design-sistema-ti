package br.com.estudo.almoxarifado.application;

import br.com.estudo.almoxarifado.domain.Material;

public interface MaterialRepository {
    void salvar(Material material);
    Material buscarPorCodigo(String codigo);
}
