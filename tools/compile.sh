#!/bin/bash
# tools/compile.sh - Compilador de módulos do Console Toolbelt

set -e

SRC_DIR="src"
DIST_DIR="dist"
TOOLS_DIR="tools"

# Verifica dependência do yq (necessário para processar YAML)
YQ="./tools/yq"
if ! command -v $YQ &> /dev/null; then
    if ! command -v yq &> /dev/null; then
        echo "Erro: 'yq' não encontrado em ./tools/yq ou no PATH." >&2
        exit 1
    else
        YQ="yq"
    fi
fi

compile_module() {
    local module_path="$1"
    local module_slug=$(basename "$module_path")
    local output_file="$DIST_DIR/${module_slug}.sh"
    local module_yaml="$module_path/module.yml"

    echo "Compilando módulo: $module_slug..."

    if [ ! -f "$module_yaml" ]; then
        echo "Aviso: Módulo $module_slug não possui module.yml. Pulando."
        return
    fi

    # Inicia o arquivo de saída
    cat <<EOF > "$output_file"
#!/bin/bash
# Módulo: $($YQ '.[] | .name' "$module_yaml")
# Descrição: $($YQ '.[] | .description' "$module_yaml")
# GERADO AUTOMATICAMENTE - NÃO EDITE ESTE ARQUIVO DIRETAMENTE

EOF

    # Processa Tabelas (Tables)
    echo "# --- Tabelas de Dados ---" >> "$output_file"
    local tables=$($YQ '.[] | .tables | keys | .[]' "$module_yaml")
    for table in $tables; do
        local table_file="$module_path/${table}.yml"
        if [ -f "$table_file" ]; then
            echo "Processando tabela: $table"
            echo "function _${module_slug}_table_${table}() {" >> "$output_file"
            echo "    case \"\$1\" in" >> "$output_file"
            # Converte YAML para cases bash
            $YQ -r 'to_entries | .[] | "        \(.key)) echo -n \"\(.value)\" ;;"' "$table_file" >> "$output_file"
            echo "    esac" >> "$output_file"
            echo "}" >> "$output_file"
        fi
    done
    echo "" >> "$output_file"

    # Incorpora arquivos privados
    echo "# --- Implementação Privada ---" >> "$output_file"
    local privates=$($YQ -r '.[] | .private[]' "$module_yaml" 2>/dev/null || echo "")
    for priv in $privates; do
        if [ -f "$module_path/$priv" ]; then
            echo "Incluindo arquivo privado: $priv"
            # Remove o shebang se existir e anexa
            grep -v '^#!' "$module_path/$priv" >> "$output_file"
        fi
    done
    echo "" >> "$output_file"

    # Incorpora funções públicas (baseadas no module.yml e arquivos .sh remanescentes)
    # Por enquanto, vamos assumir que as funções estão nos arquivos .sh
    # e o compilador apenas os junta, mas o ideal seria gerar wrappers de argumentos.
    
    echo "# --- Implementação Pública ---" >> "$output_file"
    # Pegamos todos os .sh que não são privados
    for sh_file in "$module_path"/*.sh; do
        local filename=$(basename "$sh_file")
        if [[ ! "$privates" =~ "$filename" ]]; then
             echo "Incluindo arquivo público: $filename"
             grep -v '^#!' "$sh_file" >> "$output_file"
        fi
    done

    # --- Gerador de Helpers de Argumentos (Simples) ---
    echo "# --- Helpers de Argumentos ---" >> "$output_file"
    local public_cmds=$($YQ -r ".${module_slug}.public | keys | .[]" "$module_yaml" 2>/dev/null || echo "")
    for cmd in $public_cmds; do
        local title=$($YQ -r ".${module_slug}.public.${cmd}.title" "$module_yaml")
        {
            echo "function ${module_slug}.${cmd}() {"
            echo "    if [[ \"\$1\" == \"--help\" ]]; then"
            echo "        echo \"$title\""
            echo "        return 0"
            echo "    fi"
            echo "    _${cmd} \"\$@\""
            echo "}"
        } >> "$output_file"
    done

    chmod +x "$output_file"
    echo "Módulo $module_slug compilado em $output_file"
}

# Cria diretório dist se não existir
mkdir -p "$DIST_DIR"

# Compila todos os módulos em src
for mod in "$SRC_DIR"/*; do
    if [ -d "$mod" ]; then
        compile_module "$mod"
    fi
done
