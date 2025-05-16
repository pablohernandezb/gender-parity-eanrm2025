#### Loading the libraries ####

library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)

#### Data cleaning ####

# Cargando los datos
eanr2025 <- read.csv("dataset_eanr2025_candidatos.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, encoding = "UTF-8")

# 1. Limpiar la columna state_description eliminando "EDO. "
eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("EDO. ", "", state_description))

eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("BOLIVARIANO DE ", "", state_description))

eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("DISTRITO ", "DTTO ", state_description))

eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("AMAC", "AMACURO", state_description))

## Type of election key ##
# 2  Gobernador(a) / Governor
# 7  Legislador(a) Nominal / state Representative Nominal
# 8  Legislador(a) Lista / State Representative List
# 13 Legislador(a) Indígena / Indigenous State Representative
# 20 Diputado(a) Nominal / Deputy Nominal
# 21 Diputado(a) Lista / Deputy List
# 24 Diputado(a) Indígena / Deputy Indigenous
 
#### Descriptive Analysis by Gender ####

# 1.1. Gender by State

# Agrupar por cod_state y tomar el primer state_description (o el más frecuente)
eanr2025_cleaned <- eanr2025 %>%
  group_by(cod_state) %>%
  summarise(
    state_description = first(state_description), # O puedes usar mode(state_description) para el más frecuente
    gender_M = sum(gender == "M"),
    gender_F = sum(gender == "F"),
    total_state = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    percentage_M = ifelse(total_state > 0, (gender_M / total_state) * 100, 0),
    percentage_F = ifelse(total_state > 0, (gender_F / total_state) * 100, 0)
  )

# Preparar los datos para el gráfico
plot_data <- eanr2025_cleaned %>%
  select(cod_state, state_description, percentage_M, percentage_F) %>%
  pivot_longer(cols = starts_with("percentage"),
               names_to = "gender",
               values_to = "percentage") %>%
  mutate(gender = recode(gender,
                         "percentage_M" = "M",
                         "percentage_F" = "F"))

# Crear el gráfico de barras
ggplot(plot_data, aes(x = state_description, y = percentage, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(title = "Porcentaje de Género por Estado",
       x = "Estado",
       y = "Porcentaje",
       fill = "Género") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state.png", width = 12, height = 8)

# Crear una lista de dataframes, uno por cada election_type_id
dataframes_by_election_type <- eanr2025 %>%
  group_split(election_type_id) %>%
  set_names(paste0("election_type_", unique(eanr2025$election_type_id))) # Nombra los dataframes en la lista

# Ahora 'dataframes_by_election_type' es una lista donde cada elemento es un dataframe
# Puedes acceder a un dataframe específico por su nombre, por ejemplo:
# dataframes_by_election_type$election_type_2

# Ejemplo de cómo trabajar con los dataframes (puedes adaptarlo a tus necesidades):
# Para imprimir el número de filas de cada dataframe:
for (name in names(dataframes_by_election_type)) {
  cat("Dataframe:", name, "tiene", nrow(dataframes_by_election_type[[name]]), "filas\n")
}

# Para realizar alguna operación en todos los dataframes (ejemplo: contar el número total de candidatos):
total_candidatos_por_tipo <- sapply(dataframes_by_election_type, nrow)
print(total_candidatos_por_tipo)

# O para calcular el porcentaje de hombres y mujeres en cada tipo de elección:
resultados_genero_por_tipo <- lapply(dataframes_by_election_type, function(df) {
  df %>%
    group_by(gender) %>%
    summarise(count = n(), .groups = 'drop') %>%
    mutate(percentage = count / sum(count) * 100)
})

print(resultados_genero_por_tipo)

# Si quieres guardar cada dataframe en un archivo CSV separado:
# for (name in names(dataframes_by_election_type)) {
#   write.csv(dataframes_by_election_type[[name]], paste0(name, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")
# }

# Preparar los datos para graficar
plot_data_list <- lapply(names(resultados_genero_por_tipo), function(election_type) {
  resultados_genero_por_tipo[[election_type]] %>%
    mutate(election_type = election_type)
}) %>%
  bind_rows()

# Definir el orden y las etiquetas de los tipos de elección
election_type_order <- c("election_type_2", "election_type_7", "election_type_8", "election_type_13", "election_type_20", "election_type_21", "election_type_24")
election_type_labels <- c("Gobernador(a)", "Legislador(a) Nominal", "Legislador(a) Lista", "Legislador(a) Indígena", "Diputado(a) Nominal", "Diputado(a) Lista", "Diputado(a) Indígena")

# Asegurarse de que los datos estén en el orden correcto y con las etiquetas correctas
plot_data_list$election_type <- factor(plot_data_list$election_type, levels = election_type_order, labels = election_type_labels)

# Crear el gráfico de barras
ggplot(plot_data_list, aes(x = election_type, y = percentage, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Tipo de Elección",
    x = "",
    y = "Porcentaje (%)",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_election_type_ordered.png", width = 12, height = 8)

# 2. Filtrar por election_type_id = 2
election_2_data <- eanr2025 %>%
  filter(election_type_id == 2)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_2_data %>%
  group_by(state_description, gender, list_order) %>%
  summarise(cantidad = n(), .groups = 'drop') %>%
  group_by(state_description) %>%
  mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
  ungroup()


# 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
#  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.


# 5.  Crear el gráfico de barras
ggplot(conteo_candidatos, aes(x = state_description, y = porcentaje, fill = gender)) +
  geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Estado para la elección a Gobernador(a)",
    x = "",
    y = "Porcentaje",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state_election_type_2.png", width = 12, height = 8)

# 2. Filtrar por election_type_id = 7
election_7_data <- eanr2025 %>%
  filter(election_type_id == 7)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_7_data %>%
  group_by(state_description, gender, list_order) %>%
  summarise(cantidad = n(), .groups = 'drop') %>%
  group_by(state_description, list_order) %>%
  mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
  ungroup()


# 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
#  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.


# 5.  Crear el gráfico de barras
ggplot(conteo_candidatos, aes(x = state_description, y = porcentaje, fill = gender)) +
  geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
  facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Estado y posición para la elección a Legislador(a) Nominal",
    x = "",
    y = "Porcentaje",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state_election_type_7.png", width = 12, height = 8)


# 2. Filtrar por election_type_id = 13
election_13_data <- eanr2025 %>%
  filter(election_type_id == 13)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_13_data %>%
  group_by(state_description, gender, list_order) %>%
  summarise(cantidad = n(), .groups = 'drop') %>%
  group_by(state_description, list_order) %>%
  mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
  ungroup()


# 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
#  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.


# 5.  Crear el gráfico de barras
ggplot(conteo_candidatos, aes(x = state_description, y = porcentaje, fill = gender)) +
  geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
  facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Estado y posición para la elección a Legislador(a) Indígena",
    x = "",
    y = "Porcentaje",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state_election_type_13.png", width = 12, height = 8)

# 2. Filtrar por election_type_id = 20
election_20_data <- eanr2025 %>%
  filter(election_type_id == 20)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_20_data %>%
  group_by(state_description, gender, list_order) %>%
  summarise(cantidad = n(), .groups = 'drop') %>%
  group_by(state_description, list_order) %>%
  mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
  ungroup()


# 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
#  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.


# 5.  Crear el gráfico de barras
ggplot(conteo_candidatos, aes(x = state_description, y = porcentaje, fill = gender)) +
  geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
  facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Estado y posición para la elección a Diputado(a) Nominal",
    x = "",
    y = "Porcentaje",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state_election_type_20.png", width = 12, height = 8)

# 2. Filtrar por election_type_id = 24
election_24_data <- eanr2025 %>%
  filter(election_type_id == 24)


# 3. Contar candidatos por circunscripcion, género y list_order
conteo_candidatos <- election_24_data %>%
  group_by(cod_circunscription, gender, list_order) %>%
  summarise(cantidad = n(), .groups = 'drop') %>%
  group_by(cod_circunscription, list_order) %>%
  mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
  ungroup()


# 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
#  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.


# 5.  Crear el gráfico de barras
ggplot(conteo_candidatos, aes(x = cod_circunscription, y = porcentaje, fill = gender)) +
  geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
  facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Circunscripción y posición para la elección a Diputado(a) Indígena",
    x = "Cirscunscripción",
    y = "Porcentaje",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state_election_type_24.png", width = 12, height = 8)

# Filtrar por election_type_id = 8
election_8_data <- eanr2025 %>%
  filter(election_type_id == 8)


# 3. Crear los boxplots
ggplot(election_8_data, aes(x = state_description, y = list_order, fill = gender)) +
  geom_boxplot() +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Distribución de candidatos en las listas a Legislador(a)",
    x = "Estado",
    y = "Posición en la lista",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("list_order_boxplots_election_type_8.png", width = 12, height = 8)

# 2. Filtrar por election_type_id = 24
election_24_data <- eanr2025 %>%
  filter(election_type_id == 24)


# 3. Contar candidatos por circunscripcion, género y list_order
conteo_candidatos <- election_24_data %>%
  group_by(cod_circunscription, gender, list_order) %>%
  summarise(cantidad = n(), .groups = 'drop') %>%
  group_by(cod_circunscription, list_order) %>%
  mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
  ungroup()


# 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
#  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.


# 5.  Crear el gráfico de barras
ggplot(conteo_candidatos, aes(x = cod_circunscription, y = porcentaje, fill = gender)) +
  geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
  facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Porcentaje de Género por Circunscripción y posición para la elección a Diputado(a) Indígena",
    x = "Cirscunscripción",
    y = "Porcentaje",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("gender_percentage_by_state_election_type_21.png", width = 12, height = 8)

# Filtrar por election_type_id = 21
election_21_data <- eanr2025 %>%
  filter(election_type_id == 21 & cod_state != 27)

# 3. Crear los boxplots
ggplot(election_21_data, aes(x = state_description, y = list_order, fill = gender)) +
  geom_boxplot() +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Distribución de candidatos en las listas a Diputado(a)",
    x = "Estado",
    y = "Posición en la lista",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("list_order_boxplots_election_type_21.png", width = 12, height = 8)


# Filtrar por election_type_id = 21
election_21_nat_data <- eanr2025 %>%
  filter(election_type_id == 21 & cod_state == 27)

# 3. Crear los boxplots
ggplot(election_21_nat_data, aes(x = organization_short_name, y = list_order, fill = gender)) +
  geom_boxplot() +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Distribución de candidatos en las listas nacionales para elegir Diputados(as)",
    x = "Partido o Alianza",
    y = "Posición en la lista",
    fill = "Género"
  ) +
  theme_minimal() +
  scale_x_discrete(labels = c("LÁPIZ", "AREPA", "BR", "CONDE", "ALIANZA DEMOCRÁTICA", "DDP", "FV, MIN y MOVEV", "SPV", "UNE", "UNT y UNICA", "GPP")) + # Cambiar etiquetas del eje x
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Guardar el gráfico (opcional)
# ggsave("list_order_boxplots_election_type_21.png", width = 12, height = 8)
