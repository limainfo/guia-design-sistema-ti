package br.com.estudo.almoxarifado.application;

import br.com.estudo.almoxarifado.domain.Material;

public class EstoqueServiceImpl implements EstoqueService {
    private final MaterialRepository repository;
    private final EstoqueGateway gateway;

    public EstoqueServiceImpl(MaterialRepository repository, EstoqueGateway gateway) {
        this.repository = repository;
        this.gateway = gateway;
    }

    @Override
    public void cadastrarMaterial(Material material) {
        repository.salvar(material);
    }

    @Override
    public int consultarSaldo(String codigo) {
        return buscar(codigo).getSaldo();
    }

    @Override
    public void registrarEntrada(String codigo, int quantidade) {
        Material material = buscar(codigo);
        material.entrada(quantidade);
        repository.salvar(material);
        gateway.enviarAtualizacao(material);
    }

    @Override
    public void registrarSaida(String codigo, int quantidade) {
        Material material = buscar(codigo);
        material.saida(quantidade);
        repository.salvar(material);
        gateway.enviarAtualizacao(material);
    }

    private Material buscar(String codigo) {
        Material material = repository.buscarPorCodigo(codigo);
        if (material == null) {
            throw new IllegalArgumentException("Material não encontrado: " + codigo);
        }
        return material;
    }
}
