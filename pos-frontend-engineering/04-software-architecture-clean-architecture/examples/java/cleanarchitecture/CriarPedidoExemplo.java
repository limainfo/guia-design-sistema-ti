package examples.cleanarchitecture;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

/**
 * Exemplo didático compacto de Clean Architecture:
 * domínio -> caso de uso -> porta -> adaptador em memória.
 */
public final class CriarPedidoExemplo {

    // Enterprise Business Rules
    public record PedidoId(UUID valor) {
        public PedidoId {
            Objects.requireNonNull(valor);
        }
    }

    public static final class Pedido {
        private final PedidoId id;
        private final List<String> itens = new ArrayList<>();
        private boolean confirmado;

        public Pedido(PedidoId id) {
            this.id = Objects.requireNonNull(id);
        }

        public PedidoId id() {
            return id;
        }

        public void adicionarItem(String produto) {
            if (confirmado) {
                throw new IllegalStateException("Pedido já confirmado");
            }
            if (produto == null || produto.isBlank()) {
                throw new IllegalArgumentException("Produto obrigatório");
            }
            itens.add(produto);
        }

        public void confirmar() {
            if (itens.isEmpty()) {
                throw new IllegalStateException("Pedido sem itens");
            }
            confirmado = true;
        }
    }

    // Output port
    public interface PedidoRepository {
        void salvar(Pedido pedido);
        Optional<Pedido> buscarPorId(PedidoId id);
    }

    // Input port
    public interface CriarPedidoUseCase {
        PedidoId executar(List<String> produtos);
    }

    // Application Business Rules
    public static final class CriarPedidoService implements CriarPedidoUseCase {
        private final PedidoRepository repository;

        public CriarPedidoService(PedidoRepository repository) {
            this.repository = Objects.requireNonNull(repository);
        }

        @Override
        public PedidoId executar(List<String> produtos) {
            if (produtos == null || produtos.isEmpty()) {
                throw new IllegalArgumentException("Informe ao menos um produto");
            }

            var pedido = new Pedido(new PedidoId(UUID.randomUUID()));
            produtos.forEach(pedido::adicionarItem);
            pedido.confirmar();
            repository.salvar(pedido);
            return pedido.id();
        }
    }

    // Output adapter
    public static final class PedidoRepositoryEmMemoria implements PedidoRepository {
        private final Map<PedidoId, Pedido> dados = new HashMap<>();

        @Override
        public void salvar(Pedido pedido) {
            dados.put(pedido.id(), pedido);
        }

        @Override
        public Optional<Pedido> buscarPorId(PedidoId id) {
            return Optional.ofNullable(dados.get(id));
        }
    }

    private CriarPedidoExemplo() {
    }
}
