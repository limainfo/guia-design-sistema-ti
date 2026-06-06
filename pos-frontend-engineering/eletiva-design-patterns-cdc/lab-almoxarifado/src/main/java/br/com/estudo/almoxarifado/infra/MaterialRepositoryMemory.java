package br.com.estudo.almoxarifado.infra;

import java.util.HashMap;
import java.util.Map;

import br.com.estudo.almoxarifado.application.MaterialRepository;
import br.com.estudo.almoxarifado.domain.Material;

public class MaterialRepositoryMemory implements MaterialRepository {
    private final Map<String, Material> dados = new HashMap<>();

    @Override
    public void salvar(Material material) {
        dados.put(material.getCodigo(), material);
    }

    @Override
    public Material buscarPorCodigo(String codigo) {
        return dados.get(codigo);
    }
}
