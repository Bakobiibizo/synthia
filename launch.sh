#!/bin/bash

if [ "$1" = "--setup" ]; then
    create_setup
fi



create_setup() {
    cat <<'EOF' > ecosystem.config.js
    module.exports = {
    apps: [
        {
            name: `${process.env.MODULE_KEYNAME}`,
            script: 'src/synthia/cli.py',
            interpreter: 'python',
            args: process.env.MODULE_PATH,  // Using environment variable
            watch: true,
            env: {
                MODULE_ENV: 'development',
                MODULE_PATH: `${process.env.MODULE_PATH}`, // Default path that can be overridden
            }
        },
        {
            name: `${process.env.MODULE_KEYNAME}`,
            script: 'comx',
            args: `module serve --ip "${process.env.MODULE_IP}" --port "${process.env.MODULE_PORT}" --subnets-whitelist "${process.env.MODULE_NETUID}" "synthia.miner.${process.env.MODULE_PATH}" "${process.env.MODULE_KEYNAME}"`,
            watch: true,
            env: {
                MODULE_ENV: 'development',
                MODULE_IP: '0.0.0.0', // Default IP
                MODULE_PORT: '8000',    // Default Port
                MODULE_NETUID: '3',   // Default Netuid
                MODULE_PATH: 'anthropic.AnthropicModule',
                MODULE_KEYNAME: 'module',
                MODULE_STAKE: '300'
            }
        }
    ]
};
EOF
cp env/config.env.sample env/config.env
cat >> .env < EOF
ANTHROPIC_API_KEY=mk-key
EOF
echo '.env' >> .gitignore

}

configure_launch() {
    read -p "Module Path: " module_path
    read -p "Module key name: " key_name
    read -p "Create key (y/n): " createkey
    if [ "$createkey" = "y" ]; then
    create_key
    fi
    read -p "Transfer balance (y/n): " transfer_balance
    if [ "$transfer_balance" = "y" ]; then
    transfer_balance
    fi
    read -p "Module IP address: " ip_address
    read -p "Module port: " port
    read -p "Module netuid: " netuid
    read -p "Module stake: " stake
    export MODULE_PATH="$module_path"
    export MODULE_IP="$ip_address"
    export MODULE_PORT="$port"
    export MODULE_NETUID="$netuid"
    export MODULE_KEYNAME="$key_name"
    export MODULE_STAKE="$stake"
}
# Function to create a key
create_key() {
    echo "Creating key"
    if [ ! -z "$key_name" ]; then
    read -p "Key name: " key_name
    fi
    comx key create "$key_name"
    echo "$key_name created"
}


# Function to perform a balance transfer
transfer_balance() {
    echo "Initiating Balance Transfer"
    read -p "From Key (sender): " key_from
    read -p "Amount to Transfer: " amount
    if [ ! -z "$key_name" ]; then
    read -p "To Key (recipient): " key_to
    else
        key_to = $key_name
    fi
    comx balance transfer "$key_from" "$amount" "$key_to"
    echo "Transfer of $amount from $key_from to $key_to initiated."
}
# Function to deploy a miner
deploy_miner() {
    echo "Deploying Miner"
    register_miner
    serve_miner
    echo "Miner deployed."
}

serve_miner() {
    echo "Serving Miner"
    export MODULE_IP="$ip_address"
    export MODULE_PORT="$port"
    export MODULE_NETUID="$netuid"
    export MODULE_KEYNAME="$key_name"
    export MODULE_PATH="$module_path"
    export MODULE_STAKE="$stake"
    
    pm2 start "comx module serve synthia.miner.$module_path ${key_name} --ip $ip_address --port $port --subnets-whitelist $netuid" --name "$module_path"
    echo "Miner served."
}

register_miner() {
    echo "Registering Miner"
    comx module register "$module_path" "$ip_address" "$port" "$key_name" --netuid "$netuid" --stake "$stake"
    echo "Miner registered."
}

serve_validator() {
    echo "Serving Validator"
    pm2 start "python -m synthia.cli $module_path"
    echo "Validator served."
}

register_validator() {
    echo "Registering Validator"
    comx module register "$module_path" "$ip_address" "$port" "$key_name" --netuid "$netuid" --stake "$stake"
    echo "Validator registered."
}

# Function to deploy a validator
deploy_validator() {
    echo "Deploying Validator"
    serve_validator
    register_validator
    echo "Validator deployed."
}

update_module() {
    echo "Updating Module"
    comx module update $module_path $key_name $ip_address $port --netuid $netuid
    echo "Module updated."
}

if [ "$1" = "--setup" ]; then
    create_setup
fi

echo "Choose your deployment:"
echo "1. Fully Deploy Validator"
echo "2. Fully Deploy Miner"
echo "3. Fully Deploy Both"
echo "4. Register Validator"
echo "5. Register Miner"
echo "6. Serve Validator"
echo "7. Serve Miner"
echo "8. Update Module"
echo "9. Transfer Balance"
echo "10. Create Key"
read -p "Choose an action: " choice

case "$choice" in
    1)
        echo "Validator Configuration"
        configure_launch
        deploy_validator
        ;;
    2)
        echo "Miner Configuration"
        configure_launch
        deploy_miner
        ;;
    3)
        echo "Validator Configuration"
        configure_launch
        deploy_validator
        echo "Miner Configuration"
        configure_launch
        deploy_miner
        ;;
    4)
        echo "Validator Configuration"
        configure_launch
        register_validator
        ;;
    5)
        echo "Miner Configuration"
        configure_launch
        register_miner
        ;;
    6)
        echo "Validator Configuration"
        configure_launch
        serve_validator
        ;;
    7)
        echo "Miner Configuration"
        configure_launch
        serve_miner
        ;;
    8)
        echo "Module Configuration"
        configure_launch
        update_module
        ;;
    9)  
        transfer_balance
        ;;
    10)
        create_key
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "Deployment complete."
