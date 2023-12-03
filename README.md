# Aplicação de Monitoramento de Automóveis com GeoFencing e detecção de acidentes utilizando os acelerômetros.

## Executando o projeto

__Flutter (/geo_app)__ 
- Primeiro verifique se todas as dependências para executar o flutter estão instaladas: `flutter doctor`
- Execute `flutter pub get` para instalar as dependências do projeto. 
- Inicie o emulador e execute 'Run without debugging'.
- Para gerar o apk (build):  `flutter build apk` 

__Typescript/EJS (/server)__
- Instale as dependências `npm i`.
- execute em diferentes terminais os arquivos /mosquitto. (caso não utilize o broker público)
- Execute a aplicação `npm run db` para o json-server e `npm run dev` para o servidor web. 
> O servidor será executado em: http://127.0.0.1:3000