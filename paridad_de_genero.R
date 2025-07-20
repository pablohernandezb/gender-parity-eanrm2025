#### Loading the libraries ####

library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(stringr)

#### Data cleaning ####

# Cargando los datos
eanr2025 <- read.csv("dataset_eanr2025_candidatos.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, encoding = "UTF-8")
em2025 <- read.csv("dataset_em2025_candidatos.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, encoding = "UTF-8")


# 1. Limpiar la columna state_description eliminando "EDO. "
eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("EDO. ", "", state_description))

eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("BOLIVARIANO DE ", "", state_description))

eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("DISTRITO ", "DTTO ", state_description))

eanr2025 <- eanr2025 %>%
  mutate(state_description = gsub("AMAC", "AMACURO", state_description))

# 1.1 Limpiar la columna state_description eliminando "EDO. "
em2025 <- em2025 %>%
  mutate(state_description = gsub("EDO. ", "", state_description))

em2025 <- em2025 %>%
  mutate(state_description = gsub("BOLIVARIANO DE ", "", state_description))

em2025 <- em2025 %>%
  mutate(state_description = gsub("DISTRITO ", "DTTO ", state_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("MP. ", "", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("MP.", "", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("BOLIVARIANO ", "", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("AUTONOMO ", "", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("TURISTICO ", "", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("TENIENTE CORONEL", "TCNEL.", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("GENERAL EN JEFE", "GJ.", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("CAPITAN DE NAVIO", "CN.", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("GENERAL DE DIVISION", "GD.", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("ALMIRANTE", "A.", municipality_description))

em2025 <- em2025 %>%
  mutate(municipality_description = gsub("CORONEL", "CNEL.", municipality_description))


## Type of election key ##
# 2  Gobernador(a) / Governor
# 3  Alcalde(esa) / Mayor
# 7  Legislador(a) Nominal / state Representative Nominal
# 8  Legislador(a) Lista / State Representative List
# 13 Legislador(a) Indígena / Indigenous State Representative
# 15 Concejal(a) Nominal / City Council Member Nominal
# 16 Concejal(a) Lista / City Council Member List
# 17 Concejal(a) Indígena / City Council Indigenous
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

# EM2025: Agrupar por cod_state y tomar el primer state_description (o el más frecuente)
em2025_cleaned <- em2025 %>%
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
plot_data <- em2025_cleaned %>%
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

# Crear una lista de dataframes, uno por cada election_type_id
dataframes_by_election_type <- em2025 %>%
  group_split(election_type_id) %>%
  set_names(paste0("election_type_", unique(em2025$election_type_id))) # Nombra los dataframes en la lista

names(dataframes_by_election_type)<-c("election_type_3","election_type_15","election_type_16","election_type_17")


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

election_type_order <- c("election_type_3", "election_type_15", "election_type_16", "election_type_17")
election_type_labels <- c("Alcalde(sa)", "Concejal(a) Nominal", "Concejal(a) Lista", "Concejal(a) Indígena")

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

# 2. Filtrar por election_type_id = 3
election_3_data <- em2025 %>%
  filter(election_type_id == 3)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_3_data %>%
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
    title = "Porcentaje de Género por Estado para la elección a Alcalde(sa)",
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

# 2. Filtrar por election_type_id = 15
election_15_data <- em2025 %>%
  filter(election_type_id == 15)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_15_data %>%
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
    title = "Porcentaje de Género por Estado y posición para la elección a Concejal(a) Nominal",
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

# Filtrar por election_type_id = 16
election_16_data <- em2025 %>%
  filter(election_type_id == 16)

unique_states <- unique(election_16_data$cod_state)
unique_states_desc <- unique(election_16_data$state_description)


# 3. Crear los boxplots

# Loop through each state to create a separate plot
# You can uncomment this loop if you want separate plots per state
for (state_id in unique_states) {

    state_data <- election_16_data %>%
    filter(cod_state == state_id)

  plot_title <- paste("Distribución de candidatos en las listas a Concejal(a) en", str_to_title(tolower(unique_states_desc[state_id])))

  p <- ggplot(state_data, aes(x = municipality_description, y = list_order, fill = gender)) +
    geom_boxplot() +
    scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
    labs(
      title = plot_title,
      x = "Municipio",
      y = "Posición en la lista",
      fill = "Género"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  print(p) # Print the plot to display it

  # Optional: Save the plot to a file
  ggsave(filename = paste0("fig_pos_concejal_lista_", unique_states_desc[state_id], ".png"), plot = p, width = 10, height = 6, bg = "white")
}

# Alternatively, if you want a single plot with facets for states (often more manageable)
# This approach is generally recommended if you have many states and want to compare them easily.

ggplot(election_16_data, aes(x = municipality_description, y = list_order, fill = gender)) +
  geom_boxplot() +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Distribución de candidatos en las listas a Concejal(a) por Estado y Municipio",
    x = "Municipio",
    y = "Posición en la lista",
    fill = "Género"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) + # Adjust text size for readability
  facet_wrap(~ state_description, scales = "free_x", ncol = 3) # Facet by state_description

# Plot 

# Calculate the 'list_size' for each municipality
# 'list_size' is defined as the highest list_order within that municipality
df_processed <- election_16_data %>%
  group_by(municipality_description) %>%
  mutate(list_size = max(list_order, na.rm = TRUE)) %>%
  ungroup()

# Sort the data by list_size for better visualization order on the x-axis
df_processed <- df_processed %>%
  arrange(list_size)

# Convert list_size to a factor for proper discrete plotting on the x-axis
df_processed$list_size <- factor(df_processed$list_size)

# Create the boxplot
ggplot(df_processed, aes(x = list_size, y = list_order, fill = gender)) +
  geom_boxplot() +
  scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
  labs(
    title = "Distribución de Posición en Lista al Concejo Municipal por tamaño de Lista y Género",
    x = "Tamaño de Lista",
    y = "Posición en la Lista",
    fill = "Género"
  ) +
  theme_bw() + # Set white background
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8), # Rotate x-axis labels
    plot.title = element_text(hjust = 0.5) # Center the plot title
  )






# 2. Filtrar por election_type_id = 17
election_17_data <- em2025 %>%
  filter(election_type_id == 17)


# 3. Contar candidatos por estado, género y list_order
conteo_candidatos <- election_17_data %>%
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
    title = "Porcentaje de Género por Estado y posición para la elección a Concejal(a) Indígena",
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

## Some stats

# Calculate counts and percentages for each gender
gender_counts_percentages <- em2025 %>%
  count(gender) %>% # This counts the occurrences (n) of each gender
  mutate(percentage = (n / sum(n)) * 100) # This calculates the percentage

# Print the resulting table, which will show both the 'n' (count) and 'percentage'
print(gender_counts_percentages)

# Calculate counts and percentages for each gender
gender_counts_percentages <- election_3_data %>%
  count(gender) %>% # This counts the occurrences (n) of each gender
  mutate(percentage = (n / sum(n)) * 100) # This calculates the percentage

# Print the resulting table, which will show both the 'n' (count) and 'percentage'
print(gender_counts_percentages)

# Calculate counts and percentages for each gender
gender_counts_percentages <- election_15_data %>%
  count(gender) %>% # This counts the occurrences (n) of each gender
  mutate(percentage = (n / sum(n)) * 100) # This calculates the percentage

# Print the resulting table, which will show both the 'n' (count) and 'percentage'
print(gender_counts_percentages)

# Calculate counts and percentages for each gender
gender_counts_percentages <- election_16_data %>%
  count(gender) %>% # This counts the occurrences (n) of each gender
  mutate(percentage = (n / sum(n)) * 100) # This calculates the percentage

# Print the resulting table, which will show both the 'n' (count) and 'percentage'
print(gender_counts_percentages)

# Calculate counts and percentages for each gender
gender_counts_percentages <- election_17_data %>%
  count(gender) %>% # This counts the occurrences (n) of each gender
  mutate(percentage = (n / sum(n)) * 100) # This calculates the percentage

# Print the resulting table, which will show both the 'n' (count) and 'percentage'
print(gender_counts_percentages)
