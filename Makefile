.PHONY: all erlang_app c_client run_erlang run_c_client clean

# Файлы Erlang
ERL_APP_MODULES = rep_app.erl rep_sup.erl rep.erl

# Файл
C_CLIENT_SRC = req.c
C_CLIENT_EXEC = req

# ZeroMQ
ZMQ_INSTALL_DIR = $(CURDIR)/zeromq_local
ZMQ_LIB_DIR = $(ZMQ_INSTALL_DIR)/lib
ZMQ_INCLUDE_DIR = $(ZMQ_INSTALL_DIR)/include

# Rebar3
REBAR3 = ./rep/rebar3

all: erlang_app c_client

# Сборка Erlang-приложения
erlang_app: $(REBAR3)
	$(REBAR3) compile

$(REBAR3):
	@{ \
	    set -e; \
	    curl -LO rep/rebar3 https://s3.amazonaws.com/rebar3/rebar3; \
	    chmod +x rep/rebar3; \
	}

# Сборка C-клиента
c_client: $(C_CLIENT_SRC) $(ZMQ_LIB_DIR)/libzmq.a
	gcc $(C_CLIENT_SRC) -o $(C_CLIENT_EXEC) -I$(ZMQ_INCLUDE_DIR) -L$(ZMQ_LIB_DIR) -lzmq

$(ZMQ_LIB_DIR)/libzmq.a:
	@{ \
	    set -e; \
	    ZMQ_VERSION="4.3.5"; \
	    wget https://github.com/zeromq/libzmq/releases/download/v$$ZMQ_VERSION/zeromq-$$ZMQ_VERSION.tar.gz; \
	    tar -xzf zeromq-$$ZMQ_VERSION.tar.gz; \
	    cd zeromq-$$ZMQ_VERSION; \
	    LDFLAGS="" ./configure --prefix=$(ZMQ_INSTALL_DIR) --without-libsodium; \
	    make; \
	    make install; \
	    cd ..; \
	    rm -rf zeromq-$$ZMQ_VERSION zeromq-$$ZMQ_VERSION.tar.gz; \
	}


# Запуск Erlang-приложения (сервера)
run_erlang: erlang_app
	@echo "--- Запуск Erlang-приложения (сервера) ---"
	cd rep;\
	./rebar3 shell;	


# Запуск C-клиента
run_c_client: c_client
	@echo "--- Запуск C-клиента ---"
	./$(C_CLIENT_EXEC)

clean:
	@echo "--- Очистка ---"
	-rm -f $(C_CLIENT_EXEC)
	-rm -rf _build rebar3 rebar.lock erl_crash.dump
	-rm -rf $(ZMQ_INSTALL_DIR)
