# Aplicação de Monitoramento de Automóveis com GeoFencing e detecção de acidentes utilizando os acelerômetros.

## Executando o projeto

__Flutter (/geo_app)__ 
- Primeiro verifique se todas as dependências para executar o flutter estão instaladas: `flutter doctor`
- Execute `flutter pub get` para instalar as dependências do projeto. 
- Inicie o emulador e execute 'Run without debugging'.
- Para gerar o apk (build):  `flutter build apk` 

__Python (/server)__
- Crie um ambiente virtual e instale as dependências `pip install -r requirements.txt`.
- execute em diferentes terminais os arquivos /mosquitto.
- execute o servidor flask `flask --app server run`. 

> O servidor será executado em: http://127.0.0.1:3000