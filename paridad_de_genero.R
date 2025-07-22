#### Loading the libraries ####

library(dplyr)
library(tidyr)
library(ggplot2)
library(purrr)
library(stringr)
library(patchwork)
library(cowplot)
library(RColorBrewer)

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

#### Totales (EANR y EM 2025) ####

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

#### Gobernador/a (EANR 2025) ####

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

#### Alcalde/sa (EM 2025) ####

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

#### Alcalde por Estado (EM 2025) ####

# Filtrar por election_type_id = 3
election_3_data <- em2025 %>%
  filter(election_type_id == 3)

unique_states <- unique(election_3_data$cod_state)
unique_states_desc <- unique(election_3_data$state_description)


# 3. Crear los boxplots

# Loop through each state to create a separate plot
# You can uncomment this loop if you want separate plots per state
for (state_id in unique_states) {
  
  state_data <- election_3_data %>%
    filter(cod_state == state_id)
  
  # 3. Contar candidatos por estado, género y list_order
  conteo_candidatos <- state_data %>%
    group_by(municipality_description, gender, list_order) %>%
    summarise(cantidad = n(), .groups = 'drop') %>%
    group_by(municipality_description) %>%
    mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
    ungroup()
  
  
  # 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
  #  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.
  
  plot_title <- paste("Distribución de candidatos a Alcalde(sa) en", str_to_title(tolower(unique_states_desc[state_id])))
  
  # 5.  Crear el gráfico de barras
  p <- ggplot(conteo_candidatos, aes(x = municipality_description, y = porcentaje, fill = gender)) +
        geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
        scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
        labs(
          title = plot_title,
          x = "",
          y = "Porcentaje",
          fill = "Género"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p) # Print the plot to display it
  
  # Optional: Save the plot to a file
  ggsave(filename = paste0("fig_alcalde_", unique_states_desc[state_id], ".png"), plot = p, width = 10, height = 6, bg = "white")
}

#### Legislador Nominal (EANR 2025) ####

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

#### Concejal Nominal (EANR 2025) ####

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

#### Concejal Nominal por Estado (EM 2025) ####

# Filtrar por election_type_id = 15
election_15_data <- em2025 %>%
  filter(election_type_id == 15)

unique_states <- unique(election_15_data$cod_state)
unique_states_desc <- unique(election_15_data$state_description)


# 3. Crear los boxplots

# Loop through each state to create a separate plot
# You can uncomment this loop if you want separate plots per state
for (state_id in unique_states) {
  
  state_data <- election_15_data %>%
    filter(cod_state == state_id)
  
  # 3. Contar candidatos por estado, género y list_order
  conteo_candidatos <- state_data %>%
    group_by(municipality_description, gender, list_order) %>%
    summarise(cantidad = n(), .groups = 'drop') %>%
    group_by(municipality_description, list_order) %>%
    mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
    ungroup()
  
  
  # 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
  #  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.
  
  plot_title <- paste("Distribución de candidatos a Concejal(a) Nominal en", str_to_title(tolower(unique_states_desc[state_id])))
  
  # 5.  Crear el gráfico de barras
  p <- ggplot(conteo_candidatos, aes(x = municipality_description, y = porcentaje, fill = gender)) +
    geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
    facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
    scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
    labs(
      title = plot_title,
      x = "",
      y = "Porcentaje",
      fill = "Género"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p) # Print the plot to display it
  
  # Optional: Save the plot to a file
  ggsave(filename = paste0("fig_concejal_nom_", unique_states_desc[state_id], ".png"), plot = p, width = 10, height = 6, bg = "white")
}


#### Legislador Indígena (EANR 2025) ####


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

#### Concejal Lista por Estado (EM 2025) ####

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

#### Concejal Lista por tamaño de lista (EM 2025) ####

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

#### Concejal Indígena (EM 2025) ####


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

#### Concejal Indígena por Estado (EM 2025) ####

# Filtrar por election_type_id = 17
election_17_data <- em2025 %>%
  filter(election_type_id == 17)

unique_states <- unique(election_17_data$cod_state)
unique_states_desc <- unique(election_17_data$state_description)


# 3. Crear los boxplots

# Loop through each state to create a separate plot
# You can uncomment this loop if you want separate plots per state
for (state_id in unique_states) {
  
  state_data <- election_17_data %>%
    filter(cod_state == state_id)
  
  # 3. Contar candidatos por estado, género y list_order
  conteo_candidatos <- state_data %>%
    group_by(municipality_description, gender, list_order) %>%
    summarise(cantidad = n(), .groups = 'drop') %>%
    group_by(municipality_description, list_order) %>%
    mutate(porcentaje = cantidad / sum(cantidad) * 100) %>%
    ungroup()
  
  
  # 4. Preparar los datos para el gráfico (opcional, pero recomendado para ggplot2)
  #  En este caso, los datos ya están en un formato adecuado para graficar barras apiladas o agrupadas.
  
  plot_title <- paste("Distribución de candidatos a Concejal(a) Indígena en", str_to_title(tolower(unique_states_desc[which(unique_states == state_id)])))
  
  # 5.  Crear el gráfico de barras
  p <- ggplot(conteo_candidatos, aes(x = municipality_description, y = porcentaje, fill = gender)) +
    geom_bar(stat = "identity", position = "stack") + # o "stack" para barras apiladas
    facet_wrap(~list_order, labeller = labeller(list_order = c("1" = "Principal", "2" = "Suplente"))) +
    scale_fill_manual(values = c("M" = "green", "F" = "orange")) +
    labs(
      title = plot_title,
      x = "",
      y = "Porcentaje",
      fill = "Género"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p) # Print the plot to display it
  
  # Optional: Save the plot to a file
  ggsave(filename = paste0("fig_concejal_ind_", unique_states_desc[which(unique_states == state_id)], ".png"), plot = p, width = 10, height = 6, bg = "white")
}


#### Diputado Nominal a la AN (EANR 2025) ####

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

#### Legislador Lista (EANR 2025) ####

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

#### Diputados Indígena a la AN (EANR 2025) ####

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

#### Listas por Estado a la AN (EANR 2025) ####

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

#### Listas Nacionales a la AN (EANR 2025) ####

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

#### Total number of candidates per elections and percentages ####

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


#### Generate Municipality Plot ####

# --- 1. Define input parameters ---
TARGET_STATE <- 13
TARGET_MUNICIPALITY <- 19

ELECTION_ID_MAYOR <- 3
ELECTION_ID_NOMINAL_COUNCIL <- 15
ELECTION_ID_LIST_COUNCIL <- 16
ELECTION_ID_INDIGENOUS_COUNCIL <- 17

# --- 2. Load and Filter Data ---
# Ensure 'election_type_16.csv' is in your R working directory
# or provide the full path.
#em_data <- read.csv('election_type_16.csv')

# Filter data for the specific state and municipality
filtered_em_data <- em2025 %>%
  filter(cod_state == TARGET_STATE, cod_municipality == TARGET_MUNICIPALITY)

state_name <- str_to_title(tolower(filtered_em_data$state_description[1]))
municipality_name <- str_to_title(tolower(filtered_em_data$municipality_description[1]))

# --- 3. Data Preparation for Each Plot Component ---

# Define a consistent color palette for gender
gender_colors <- c("M" = "green", "F" = "orange")

# --- A. Mayor Data (Percentages) ---
mayor_data <- filtered_em_data %>%
  filter(election_type_id == ELECTION_ID_MAYOR) %>%
  count(gender) %>%
  mutate(percentage = (n / sum(n)) * 100)

# --- B. Nominal City Council Data (Percentages by Principal/Substitute) ---
nominal_council_data_processed <- filtered_em_data %>%
  filter(election_type_id == ELECTION_ID_NOMINAL_COUNCIL) %>%
  filter(list_order %in% c(1, 2)) %>%
  mutate(candidate_type = case_when(
    list_order == 1 ~ "Principal",
    list_order == 2 ~ "Suplente",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(candidate_type)) %>%
  group_by(candidate_type, gender) %>%
  summarise(n = n(), .groups = 'drop') %>%
  group_by(candidate_type) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

# --- C. Indigenous City Council Data (Percentages by Principal/Substitute - check if exists) ---
indigenous_council_data_processed <- filtered_em_data %>%
  filter(election_type_id == ELECTION_ID_INDIGENOUS_COUNCIL) %>%
  filter(list_order %in% c(1, 2)) %>%
  mutate(candidate_type = case_when(
    list_order == 1 ~ "Principal",
    list_order == 2 ~ "Suplente",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(candidate_type)) %>%
  group_by(candidate_type, gender) %>%
  summarise(n = n(), .groups = 'drop') %>%
  group_by(candidate_type) %>%
  mutate(percentage = (n / sum(n)) * 100) %>%
  ungroup()

# --- D. List City Council Data (Boxplot - uses actual list_order as position) ---
list_council_data <- filtered_em_data %>%
  filter(election_type_id == ELECTION_ID_LIST_COUNCIL) %>%
  group_by(municipality_description) %>%
  mutate(list_size = max(list_order, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(list_size)

list_council_data$list_size <- factor(list_council_data$list_size)


# --- 4. Create Individual Plots ---

# Plot 1: Mayor (Non-stacked version)
plot_mayor <- ggplot(mayor_data, aes(x = "Alcalde(sa)", y = percentage, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.5) +
  # Updated label format to show raw number (percentage)
  geom_text(aes(label = sprintf("%d (%.1f%%)", n, percentage)),
            position = position_dodge(width = 0.5), vjust = -0.5, color = "black", size = 3) +
  scale_fill_manual(values = gender_colors) +
  labs(title = "Alcalde(sa)", y = "% de candidatos(as)", x = "") +
  ylim(0, 100) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.position = "none")

# Plot 2: Nominal City Council Member (Principal vs. Suplente - Non-stacked)
plot_nominal_council <- ggplot(nominal_council_data_processed, aes(x = candidate_type, y = percentage, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  # Updated label format to show raw number (percentage)
  geom_text(aes(label = sprintf("%d (%.1f%%)", n, percentage)),
            position = position_dodge(width = 0.7), vjust = -0.5, color = "black", size = 3) +
  scale_fill_manual(values = gender_colors) +
  labs(title = "Concejal(a) Nominal", y = "", x = "") +
  ylim(0, 100) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

# Plot 3: Indigenous City Council Member (Conditional, Principal vs. Suplente - Non-stacked)
plot_indigenous_council <- NULL
if (nrow(indigenous_council_data_processed) > 0) {
  plot_indigenous_council <- ggplot(indigenous_council_data_processed, aes(x = candidate_type, y = percentage, fill = gender)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7) +
    # Updated label format to show raw number (percentage)
    geom_text(aes(label = sprintf("%d (%.1f%%)", n, percentage)),
              position = position_dodge(width = 0.7), vjust = -0.5, color = "black", size = 3) +
    scale_fill_manual(values = gender_colors) +
    labs(title = "Concejal(a) Indígena", y = "", x = "") +
    ylim(0, 100) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = "none")
}


# Plot 4: List City Council Member (Boxplot)
plot_list_council <- ggplot(list_council_data, aes(x = list_size, y = list_order, fill = gender)) +
  geom_boxplot() +
  scale_fill_manual(values = gender_colors) +
  labs(title = "Concejal(a) Lista",
       x = "Tamaño de la lista",
       y = "Posición en la lista",
       fill = "Género") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.position = "bottom")

# --- 5. Arrange Plots Using patchwork ---

# Create a common legend from one of the plots (e.g., plot_list_council)
# Use cowplot::get_legend to extract the legend
common_legend <- cowplot::get_legend(plot_list_council + theme(legend.box.margin = margin(0, 0, 0, 12)))

# Remove individual legends from sub-plots before combining
plot_mayor <- plot_mayor + theme(legend.position = "none")
plot_nominal_council <- plot_nominal_council + theme(legend.position = "none")
if (!is.null(plot_indigenous_council)) {
  plot_indigenous_council <- plot_indigenous_council + theme(legend.position = "none")
}
plot_list_council <- plot_list_council + theme(legend.position = "none") # Remove its legend from subplot area

# Combine plots based on existence of indigenous data
if (!is.null(plot_indigenous_council)) {
  # Arrange bar plots in a row, then the boxplot below, and common legend at bottom
  combined_plot <- (plot_mayor + plot_nominal_council + plot_indigenous_council) /
    plot_list_council /
    common_legend +
    plot_layout(heights = c(1, 1, 0.1)) + # Adjust heights for plots and legend
    plot_annotation(
      title = paste0("Candidatos por género en el\nMunicipio ", municipality_name, " (Estado ", state_name, ")"),
      theme = theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"))
    )
} else {
  # Arrange bar plots in a row, then the boxplot below, and common legend at bottom
  combined_plot <- (plot_mayor + plot_nominal_council) /
    plot_list_council /
    common_legend +
    plot_layout(heights = c(1, 1, 0.1)) + # Adjust heights for plots and legend
    plot_annotation(
      title = paste0("Candidatos por género en el\nMunicipio ", municipality_name, " (Estado ", state_name, ")"),
      theme = theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"))
    )
}

# Print the combined plot
print(combined_plot)

#### Índice de Paridad de Género Estadal y Municipal (EM 2025) ####

# --- 1. Cargar Datos ---
#em_data <- read.csv('election_type_16.csv')

# --- 2. Definir IDs de Tipos de Elección ---
ELECTION_ID_MAYOR <- 3
ELECTION_ID_NOMINAL_COUNCIL <- 15
ELECTION_ID_INDIGENOUS_COUNCIL <- 17
ELECTION_ID_LIST_COUNCIL <- 16

# --- FUNCIONES AUXILIARES PARA CADA CÁLCULO DE PARIDAD ---
# (Estas funciones son las mismas que en la respuesta anterior, las incluimos por completitud)

# Función para calcular la paridad de Alcalde(sa)
calculate_parity_mayor <- function(data_group) {
  mayor_candidates <- filter(data_group, election_type_id == ELECTION_ID_MAYOR)
  total_candidates <- nrow(mayor_candidates)
  if (total_candidates == 0) {
    NA_real_
  } else {
    (sum(mayor_candidates$gender == "F") / total_candidates) * 100
  }
}

# Función para calcular la paridad de Concejal(a) Nominal o Indígena
calculate_parity_nominal_indigenous <- function(data_group, election_id) {
  candidates <- filter(data_group, election_type_id == election_id, list_order %in% c(1, 2))
  
  principal_candidates <- filter(candidates, list_order == 1)
  total_principals <- nrow(principal_candidates)
  Paridad_Principal <- if (total_principals == 0) NA_real_ else (sum(principal_candidates$gender == "F") / total_principals) * 100
  
  suplente_candidates <- filter(candidates, list_order == 2)
  total_suplentes <- nrow(suplente_candidates)
  Paridad_Suplente <- if (total_suplentes == 0) NA_real_ else (sum(suplente_candidates$gender == "F") / total_suplentes) * 100
  
  if (is.na(Paridad_Principal) && is.na(Paridad_Suplente)) {
    NA_real_
  } else {
    mean(c(Paridad_Principal, Paridad_Suplente), na.rm = TRUE)
  }
}

# Función para calcular la paridad de Concejal(a) Lista
calculate_parity_list <- function(data_group) {
  list_candidates <- filter(data_group, election_type_id == ELECTION_ID_LIST_COUNCIL)
  total_list_candidates <- nrow(list_candidates)
  
  if (total_list_candidates == 0) {
    NA_real_
  } else {
    # Componente 1: Porcentaje de Mujeres en la Lista
    perc_women_list <- (sum(list_candidates$gender == "F") / total_list_candidates) * 100
    
    # Componente 2: Paridad de Posición Promedio Normalizada
    avg_pos_women <- mean(filter(list_candidates, gender == "F")$list_order, na.rm = TRUE)
    avg_pos_men <- mean(filter(list_candidates, gender == "M")$list_order, na.rm = TRUE)
    
    if (is.nan(avg_pos_women)) avg_pos_women <- NA_real_
    if (is.nan(avg_pos_men)) avg_pos_men <- NA_real_
    
    normalized_pos_parity <- NA_real_
    if (!is.na(avg_pos_women) && !is.na(avg_pos_men)) {
      diff_avg_pos <- avg_pos_men - avg_pos_women
      max_list_order_municipality <- max(list_candidates$list_order, na.rm = TRUE)
      
      if (max_list_order_municipality <= 1 || is.nan(diff_avg_pos)) {
        normalized_pos_parity <- 100
      } else {
        min_possible_diff = 1 - max_list_order_municipality
        max_possible_diff = max_list_order_municipality - 1
        
        if (max_possible_diff == min_possible_diff) {
          normalized_pos_parity <- 100
        } else {
          normalized_pos_parity <- ((diff_avg_pos - min_possible_diff) / (max_possible_diff - min_possible_diff)) * 100
        }
      }
    } else if (is.na(avg_pos_women) || is.na(avg_pos_men)) {
      normalized_pos_parity <- 100
    }
    
    # Componente 3: Porcentaje de Mujeres en la Primera Mitad de la Lista
    first_half_max_order <- ceiling(max(list_candidates$list_order, na.rm = TRUE) / 2)
    first_half_candidates <- filter(list_candidates, list_order <= first_half_max_order)
    total_in_first_half <- nrow(first_half_candidates)
    perc_women_first_half <- if (total_in_first_half == 0) NA_real_ else (sum(first_half_candidates$gender == "F") / total_in_first_half) * 100
    
    mean(c(perc_women_list, normalized_pos_parity, perc_women_first_half), na.rm = TRUE)
  }
}


# --- 3. Calcular Métricas de Paridad por Municipio (¡USANDO do()!) ---
# Agrupar por estado y municipio
municipal_parity_metrics <- em2025 %>%
  group_by(cod_state, cod_municipality, state_description, municipality_description) %>%
  do({
    # 'dot' representa el subconjunto de datos para el grupo actual
    group_data <- .
    
    # Llamar a las funciones auxiliares con los datos del grupo actual
    Paridad_Alcalde_val <- calculate_parity_mayor(group_data)
    Paridad_Nominal_val <- calculate_parity_nominal_indigenous(group_data, ELECTION_ID_NOMINAL_COUNCIL)
    Paridad_Indigena_val <- calculate_parity_nominal_indigenous(group_data, ELECTION_ID_INDIGENOUS_COUNCIL)
    Paridad_Lista_val <- calculate_parity_list(group_data)
    
    # Devolver una tabla de una sola fila con los resultados para este grupo
    tibble(
      Paridad_Alcalde = Paridad_Alcalde_val,
      Paridad_Nominal = Paridad_Nominal_val,
      Paridad_Indigena = Paridad_Indigena_val,
      Paridad_Lista = Paridad_Lista_val
    )
  }) %>%
  ungroup() # Desagrupar el resultado final

# --- 4. Calcular el Índice de Paridad de Género (IPG) a Nivel Municipal ---
municipal_gpi <- municipal_parity_metrics %>%
  rowwise() %>% # Necesario para aplicar mean por fila
  mutate(GPI_Municipal = mean(c(Paridad_Alcalde, Paridad_Nominal, Paridad_Indigena, Paridad_Lista), na.rm = TRUE)) %>%
  ungroup()

municipal_gpi <- municipal_parity_metrics %>%
  rowwise() %>% # Necesario para aplicar mean por fila
  mutate(GPI_Municipal_wo_Ind = mean(c(Paridad_Alcalde, Paridad_Nominal, Paridad_Lista), na.rm = TRUE)) %>%
  ungroup()

# --- 5. Calcular el Índice de Paridad de Género (IPG) a Nivel Estatal ---
state_gpi <- municipal_gpi %>%
  group_by(cod_state, state_description) %>%
  summarise(GPI_State = mean(GPI_Municipal, na.rm = TRUE), .groups = 'drop')

state_gpi <- municipal_gpi %>%
  group_by(cod_state, state_description) %>%
  summarise(GPI_State_wo_Ind = mean(GPI_Municipal_wo_Ind, na.rm = TRUE), .groups = 'drop')

# --- 6. Mostrar Resultados ---

print("Índice de Paridad de Género a Nivel Municipal:")
print(municipal_gpi %>% select(cod_state, municipality_description, Paridad_Alcalde, Paridad_Nominal, Paridad_Indigena, Paridad_Lista, GPI_Municipal))

print("Índice de Paridad de Género a Nivel Estatal:")
print(state_gpi)


# Define el título común para la leyenda
legend_title <- "Paridad\nAlcalde(sa) (%)"

# Crea el scatterplot con leyendas combinadas forzadas
scatterplot_combined_legend_forced <- ggplot(municipal_parity_metrics, aes(
  x = Paridad_Lista,
  y = Paridad_Nominal,
  size = Paridad_Alcalde,
  color = Paridad_Alcalde
)) +
  # Usa geom_jitter() en lugar de geom_point()
  # Puedes ajustar 'width' y 'height' para controlar la cantidad de jitter
  geom_jitter(alpha = 0.8, width = 0.5, height = 0.5) +
  scale_size_continuous(
    # Establece 'guide = "none"' para suprimir la leyenda de tamaño
    range = c(2, 10),
    guide = "none"
  ) +
  scale_color_gradient(
    name = legend_title, # Este será el título de la leyenda principal
    low = "green",
    high = "orange",
    limits = c(0, 100)
  ) +
  labs(
    title = "Componentes del Índice de Paridad Municipal",
    subtitle = "Elecciones Locales del 27 de julio en Venezuela",
    x = "Paridad de Concejal(a) por Lista (%)",
    y = "Paridad de Concejal(a) Nominal (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 10, color = "gray50"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 10, face = "bold")
  ) +
  # Fuerza la leyenda combinada usando guides()
  guides(
    color = guide_colorbar(
      title = legend_title, # Usa el título común
      # Con 'override.aes', los puntos en la leyenda de color también variarán de tamaño
      # Esto hace que la leyenda de color represente ambos estéticos
      override.aes = list(
        size = seq(from = 2, to = 10, length.out = 5) # Muestra 5 tamaños de puntos en la leyenda
      )
    )
  ) +
  xlim(20, 80) +
  ylim(20, 80)

# Muestra el scatterplot
print(scatterplot_combined_legend_forced)

#### Gráfico de los componentes del IPGM (EM 2025) #### 

# Suponiendo que 'municipal_parity_metrics' ya ha sido creada
# y contiene las columnas 'Paridad_Alcalde', 'Paridad_Nominal' y 'Paridad_Lista'.

# Paso 1: Crear columnas booleanas para cada condición de 50% o más
municipal_parity_flags <- municipal_parity_metrics %>%
  mutate(
    over_50_alcalde = Paridad_Alcalde >= 50,
    over_50_nominal = Paridad_Nominal >= 50,
    over_50_lista = Paridad_Lista >= 50
  )

# Paso 2: Calcular las cuentas para cada condición y combinación
parity_counts_table <- tribble(
  ~Condition, ~Count,
  "Paridad Alcalde >= 50%", sum(municipal_parity_flags$over_50_alcalde, na.rm = TRUE),
  "Paridad Nominal >= 50%", sum(municipal_parity_flags$over_50_nominal, na.rm = TRUE),
  "Paridad Lista >= 50%", sum(municipal_parity_flags$over_50_lista, na.rm = TRUE),
  "Alcalde Y Nominal >= 50%", sum(municipal_parity_flags$over_50_alcalde & municipal_parity_flags$over_50_nominal, na.rm = TRUE),
  "Alcalde Y Lista >= 50%", sum(municipal_parity_flags$over_50_alcalde & municipal_parity_flags$over_50_lista, na.rm = TRUE),
  "Nominal Y Lista >= 50%", sum(municipal_parity_flags$over_50_nominal & municipal_parity_flags$over_50_lista, na.rm = TRUE),
  "Alcalde Y Nominal Y Lista >= 50%", sum(municipal_parity_flags$over_50_alcalde & municipal_parity_flags$over_50_nominal & municipal_parity_flags$over_50_lista, na.rm = TRUE)
)

# Paso 3: Calcular el número total de municipios
total_municipalities <- nrow(municipal_parity_metrics)

# Paso 4: Añadir la columna de porcentaje
parity_counts_table_with_percentage <- parity_counts_table %>%
  mutate(
    Percentage = (Count / total_municipalities) * 100
  )

# Imprimir la tabla de resultados con porcentajes
print(parity_counts_table_with_percentage)

# Paso 1: Definir el orden deseado de las categorías (¡tal cual como las quieres en la leyenda!)
category_order <- c(
  "Todas",
  "Alcalde(sa) y Nominal",
  "Alcalde(sa) y Lista",
  "Nominal y Lista",
  "Alcalde(sa)",
  "Nominal",
  "Lista",
  "Ninguna"
)

# Paso 2: Crear la columna categórica 'Parity_Category'
# y reordenar sus niveles de factor según 'category_order'.
municipal_parity_classified <- municipal_parity_flags %>%
  mutate(
    Parity_Category = case_when(
      over_50_alcalde & over_50_nominal & over_50_lista ~ "Todas",
      over_50_alcalde & over_50_nominal ~ "Alcalde(sa) y Nominal",
      over_50_alcalde & over_50_lista ~ "Alcalde(sa) y Lista",
      over_50_nominal & over_50_lista ~ "Nominal y Lista",
      over_50_alcalde ~ "Alcalde(sa)",
      over_50_nominal ~ "Nominal",
      over_50_lista ~ "Lista",
      TRUE ~ "Ninguna"
    ),
    # ¡Importante! Convertir a factor y establecer los niveles para el orden
    Parity_Category = factor(Parity_Category, levels = category_order)
  )

# Paso 3: Generar una secuencia de colores para el degradado discreto
# El color más alto (naranja) para "Todas" y el más bajo (verde) para "Ninguna".
start_color <- "orange"
end_color <- "green"

# Crear una función de paleta de colores
color_palette_func <- colorRampPalette(c(start_color, end_color))

# Generar la cantidad de colores necesaria (según el número de categorías)
num_categories <- length(category_order)
gradient_colors <- color_palette_func(num_categories)

# Asignar los nombres de las categorías a los colores generados,
# asegurando que el orden de los colores coincida con el orden de las categorías.
names(gradient_colors) <- category_order

# Paso 4: Regenerar el scatterplot con la paleta de colores manual y el orden
scatterplot_custom_color_order <- ggplot(municipal_parity_classified, aes(
  x = Paridad_Lista,
  y = Paridad_Nominal,
  size = Paridad_Alcalde,
  color = Parity_Category # Usa la variable categórica reordenada
)) +
  geom_jitter(alpha = 0.8, width = 0.5, height = 0.5) +
  scale_size_continuous(
    range = c(2, 10),
    name = "Paridad\nAlcalde(sa) (%)"
  ) +
  # Usar scale_color_manual para asignar tus colores específicos
  scale_color_manual(
    values = gradient_colors, # La paleta de colores generada
    name = "Clasificación de Paridad" # Título de la leyenda de color
  ) +
  labs(
    title = "Paridad en Concejo (Lista vs. Nominal) por Clasificación",
    subtitle = "Tamaño: Paridad de Alcalde(sa) | Color: Clasificación de Paridad",
    x = "Paridad de Concejal(a) por Lista (%)",
    y = "Paridad de Concejal(a) Nominal (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 10, color = "gray50"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 10, face = "bold")
  ) +
  xlim(20, 80) +
  ylim(20, 80)

# Muestra el scatterplot
print(scatterplot_custom_color_order)