package br.com.estudo.almoxarifado.infra;

import br.com.estudo.almoxarifado.application.EstoqueGateway;
import br.com.estudo.almoxarifado.domain.Material;

public class EstoqueGatewayLog implements EstoqueGateway {
    @Override
    public void enviarAtualizacao(Material material) {
        System.out.println("Atualização enviada: " + material.getCodigo() + " saldo=" + material.getSaldo());
    }
}
