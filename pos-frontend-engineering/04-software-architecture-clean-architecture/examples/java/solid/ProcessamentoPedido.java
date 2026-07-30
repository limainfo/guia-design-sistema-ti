package examples.solid;

import java.util.Map;
import java.util.Objects;

/**
 * Exemplo didático: cada tipo de pedido possui seu próprio processador.
 * Um novo tipo pode ser adicionado sem modificar os processadores existentes.
 */
public final class ProcessamentoPedido {

    public record Pedido(String id, String tipo) {
        public Pedido {
            Objects.requireNonNull(id);
            Objects.requireNonNull(tipo);
        }
    }

    public interface ProcessadorPedido {
        String tipoSuportado();
        void processar(Pedido pedido);
    }

    public static final class ProcessadorOnline implements ProcessadorPedido {
        @Override
        public String tipoSuportado() {
            return "ONLINE";
        }

        @Override
        public void processar(Pedido pedido) {
            System.out.printf("Processando pedido online %s%n", pedido.id());
        }
    }

    public static final class ProcessadorVarejo implements ProcessadorPedido {
        @Override
        public String tipoSuportado() {
            return "VAREJO";
        }

        @Override
        public void processar(Pedido pedido) {
            System.out.printf("Processando pedido de varejo %s%n", pedido.id());
        }
    }

    public static final class ProcessarPedidoUseCase {
        private final Map<String, ProcessadorPedido> processadores;

        public ProcessarPedidoUseCase(Iterable<ProcessadorPedido> processadores) {
            var mapa = new java.util.HashMap<String, ProcessadorPedido>();
            for (var processador : processadores) {
                mapa.put(processador.tipoSuportado(), processador);
            }
            this.processadores = Map.copyOf(mapa);
        }

        public void executar(Pedido pedido) {
            var processador = processadores.get(pedido.tipo());
            if (processador == null) {
                throw new IllegalArgumentException(
                    "Tipo de pedido não suportado: " + pedido.tipo());
            }
            processador.processar(pedido);
        }
    }

    private ProcessamentoPedido() {
    }
}
