from pyspark.sql import SparkSession
from datetime import datetime
import findspark

findspark.init()

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

print(" ===//===//===//===//===//===//>> Inicia a SparkSession")
spark = SparkSession.builder\
    .appName(f"Filtragem de dados - {timestamp}")\
    .config("spark.hadoop.security.authentication", "simple")\
    .config("spark.hadoop.security.authorization", "false")\
    .getOrCreate()

print(" ===//===//===//===//===//===//>> Cria um DataFrame simples com alguns dados")
columns = ["id", "nome", "idade"]
data = [
    (1, "Vinicius", 23),
    (2, "Allana", 21),
    (3, "Vital", 22),
    (4, "Gabriela", 25)
]

df = spark.createDataFrame(data, columns)

print(" ===//===//===//===//===//===//>> Filtra o DataFrame (idade menor que 23)")
filtered_df = df.filter(df.idade < 23)

print(" ===//===//===//===//===//===//>> Salva o DataFrame filtrado em um arquivo de CSV")
output_path = "/opt/bitnami/spark/conf/output/filtered_data.csv"
filtered_df.write.csv(output_path, header=True)

filtered_df.show(truncate=False)

print(" ===//===//===//===//===//===//>> Encerra a SparkSession")
spark.stop()
