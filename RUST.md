# RUST TODO

```bash
PROXY=http://127.0.0.1:12345
export HTTP_PROXY=${PROXY}
export HTTPS_PROXY=${PROXY}
export ALL_PROXY=${PROXY}
export NO_PROXY="localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.*,*.myqcloud.com,*.tsinghua.edu.cn"
alias build="HTTPS_PROXY=${PROXY} cargo pgrx package -v"
. ~/.cargo/env
cd ~/deb

alias pg17="export PATH=/usr/lib/postgresql/17/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;"
alias pg16="export PATH=/usr/lib/postgresql/16/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;"
alias pg15="export PATH=/usr/lib/postgresql/15/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;"
alias pg14="export PATH=/usr/lib/postgresql/14/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;"
alias pg13="export PATH=/usr/lib/postgresql/13/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;"
alias pg12="export PATH=/usr/lib/postgresql/12/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;"

```


```bash
echo "Host github.com
    Hostname ssh.github.com
    Port 443
    User git" >> ~/.ssh/config

ssh -T git@github.com
```


--------


```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

```bash
cargo install --locked cargo-pgrx@${PGRX_VER-'0.12.9'} # <--- 
cargo install --locked cargo-pgrx@${PGRX_VER-'0.11.4'}
cargo install --locked cargo-pgrx@${PGRX_VER-'0.10.2'}
cargo pgrx init
```




--------

## Rust扩展清单

| Vendor        | Name                                                       | Version | PGRX                                                                                            | License                                                                     | PG Ver            | Deps          |
|---------------|------------------------------------------------------------|---------|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|-------------------|---------------|
| Supabase      | [pg_graphql](https://github.com/supabase/pg_graphql)       | v1.5.9  | [v0.12.5](https://github.com/supabase/pg_graphql/blob/master/Cargo.toml#L17)                    | [Apache-2.0](https://github.com/supabase/pg_graphql/blob/master/LICENSE)    | 17,16,15          |               |
| Supabase      | [pg_jsonschema](https://github.com/supabase/pg_jsonschema) | v0.3.2  | [v0.12.5](https://github.com/supabase/pg_jsonschema/blob/master/Cargo.toml#L19)                 | [Apache-2.0](https://github.com/supabase/pg_jsonschema/blob/master/LICENSE) | 17,16,15,14,13,12 |               |
| Supabase      | [wrappers](https://github.com/supabase/wrappers)           | v0.4.3  | [v0.12.6](https://github.com/supabase/wrappers/blob/main/Cargo.lock#L4254)                      | [Apache-2.0](https://github.com/supabase/wrappers/blob/main/LICENSE)        | 17,16,15,14       |               |
| TimescaleDB   | [vectorscale](https://github.com/timescale/pgvectorscale)  | v0.3.0  | [v0.12.5](https://github.com/timescale/pgvectorscale/blob/main/pgvectorscale/Cargo.toml#L17)    | [PostgreSQL](https://github.com/timescale/pgvectorscale/blob/main/LICENSE)  | 17,16,15,14,13,12 |               |
| kelvich       | [pg_tiktoken](https://github.com/Vonng/pg_tiktoken)        | v0.0.1  | [v0.12.6](https://github.com/Vonng/pg_tiktoken/blob/main/Cargo.toml)                            | [Apache-2.0](https://github.com/kelvich/pg_tiktoken/blob/main/LICENSE)      | 16,15,14,13,12    |               |
| PostgresML    | [pgml](https://github.com/postgresml/postgresml)           | v2.9.3  | [v0.11.3](https://github.com/postgresml/postgresml/blob/master/pgml-extension/Cargo.lock#L1785) | [MIT](https://github.com/postgresml/postgresml/blob/master/MIT-LICENSE.txt) | 16,15,14          |               |
| Tembo         | [pg_vectorize](https://github.com/tembo-io/pg_vectorize)   | v0.17.0 | [v0.11.3](https://github.com/tembo-io/pg_vectorize/blob/main/extension/Cargo.toml#L24)          | [PostgreSQL](https://github.com/tembo-io/pg_vectorize/blob/main/LICENSE)    | 16,15,14          | pgmq, pg_cron |
| Tembo         | [pg_later](https://github.com/tembo-io/pg_later)           | v0.1.1  | [v0.11.3](https://github.com/tembo-io/pg_later/blob/main/Cargo.toml#L23)                        | [PostgreSQL](https://github.com/tembo-io/pg_later/blob/main/LICENSE)        | 16,15,14,13       | pgmq          |
| kaspermarstal | [plprql](https://github.com/kaspermarstal/plprql)          | v0.1.0  | [v0.11.3](https://github.com/kaspermarstal/plprql/blob/main/Cargo.toml#L21)                     | [Apache-2.0](https://github.com/kaspermarstal/plprql/blob/main/LICENSE)     | 16,15,14,13,12    |               |
| VADOSWARE     | [pg_idkit](https://github.com/VADOSWARE/pg_idkit)          | v0.2.3  | v0.12.5                                                                                         | [Apache-2.0](https://github.com/VADOSWARE/pg_idkit/blob/main/LICENSE)       | 17,16,15,14,13,12 |               |
| pgsmcrypto    | [pgsmcrypto](https://github.com/Vonng/pgsmcrypto)          | v0.1.0  | v0.12.6                                                                                         | [MIT](https://github.com/zhuobie/pgsmcrypto/blob/main/LICENSE)              | 17,16,15,14,13,12 |               |
| rustprooflabs | [pgdd](https://github.com/rustprooflabs/pgdd)              | v0.5.2  | [v0.10.2](https://github.com/rustprooflabs/pgdd/blob/main/Cargo.toml#L25)                       | [MIT](https://github.com/zhuobie/pgsmcrypto/blob/main/LICENSE)              | 16,15,14,13,12    |               |
| CrunchyData   | [pg_parquet](https://github.com/CrunchyData/pg_parquet)    | v0.1.0  | [v0.12.6](https://github.com/CrunchyData/pg_parquet)                                            | [PostgreSQL](https://github.com/CrunchyData/pg_parquet/blob/main/LICENSE)   | 17, 16            |               |

--------

## 下载并构建Rust扩展

```bash
cd ~;
cd ~; git clone --recursive git@github.com:postgresml/postgresml.git  ; cd ~/postgresml     && git checkout v2.9.3
cd ~; git clone git@github.com:supabase/pg_graphql.git                ; cd ~/pg_graphql     #&& git checkout v1.5.9             
cd ~; git clone git@github.com:supabase/pg_jsonschema.git             ; cd ~/pg_jsonschema  #&& git checkout v0.3.2       
cd ~; git clone git@github.com:supabase/wrappers.git                  ; cd ~/wrappers       && git checkout v0.4.3               
cd ~; git clone git@github.com:zhuobie/pgsmcrypto.git                 ; cd ~/pgsmcrypto
cd ~; git clone git@github.com:kelvich/pg_tiktoken.git                ; cd ~/pg_tiktoken
cd ~; git clone git@github.com:VADOSWARE/pg_idkit.git                 ; cd ~/pg_idkit       && git checkout v0.2.4             
cd ~; git clone git@github.com:timescale/pgvectorscale.git            ; cd ~/pgvectorscale  && git checkout 0.5.1                    

cd ~; git clone git@github.com:tembo-io/pg_vectorize.git              ; cd ~/pg_vectorize   && git checkout v0.18.3 
cd ~; git clone git@github.com:tembo-io/pg_later.git                  ; cd ~/pg_later       && git checkout v0.1.3           
cd ~; git clone git@github.com:kaspermarstal/plprql.git               ; cd ~/plprql         && git checkout v1.0.0
cd ~; git clone git@github.com:rustprooflabs/pgdd.git                 ; cd ~/pgdd           && git checkout 0.5.2

cd ~; git@github.com:CrunchyData/pg_parquet.git                       ; cd ~/pg_parquet     && git checkout 0.1.1

#cd ~; git clone git@github.com:tembo-io/pgmq.git                      ; cd ~/pgmq           && git checkout v1.2.1 #v1.3.3
#cd ~; git clone --recursive https://github.com/paradedb/paradedb.git  ; cd ~/paradedb       && git checkout v0.8.6
#cd ~/paradedb;     cargo update
```

您可以使用扩展别名，批量构建 Rust 扩展：

```bash
# pgrx 0.12.7
cd ~/pg_graphql;                  pg17 build; pg16 build; pg15 build; pg14 build;  
cd ~/pg_jsonschema;               pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/wrappers/wrappers;           pg17 build; pg16 build; pg15 build; pg14 build;
cd ~/pgsmcrypto;                  pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/pg_tiktoken;                 pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/pg_idkit;                    pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 

cd ~/pg_parquet;                  pg17 build; pg16 build; pg15 build; pg14 build;
cd ~/pg_polyline;                 pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/pg_explain_ui;               pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/pg_cardano;                  pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/pg_base58;                   pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
cd ~/pg_summarize;                pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 
export RUSTFLAGS="-C target-feature=+avx2,+fma"
cd ~/pgvectorscale/pgvectorscale; pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; 

# pgrx 0.11.3
cd ~/plprql/plprql;               pg16 build; pg15 build; pg14 build; pg13 build; pg12 build;
cd ~/pg_later;                    pg16 build; pg15 build; pg14 build; pg13 build; 
cd ~/pg_vectorize/extension;      pg16 build; pg15 build; pg14 build;
 
# pgrx 0.10.2
cd ~/pgdd;                        pg17 build; pg16 build; pg15 build; pg14 build; pg13 build; pg12 build; 


```


```bash
rm -rf ~/pg_parquet; mkdir ~/pg_parquet; tar -xf ~/pigsty-deb/tarball/pg_parquet-0.1.0.tar.gz --strip-components 1 -C ~/pg_parquet

```