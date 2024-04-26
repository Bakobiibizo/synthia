import subprocess
from subprocess import Popen
from typing_extensions import List
import argparse

def start_detached_process(command: List[str]):
    return subprocess.Popen(
        f"nohup {' '.join(command)} &",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
        text=True,
    )

def run_command(command_choice: str, args: argparse.Namespace):
    command_map = {
        "serve_miner": [
            "comx", 
            "module", 
            "serve",
            args.key_name,
            f"miner.{args.module_path}",
            "--subnets-whitelist",
            args.netuid
            ],
        "serve_validator": [
            "python", 
            "-m", 
            "synthia.cli",
            "--key_name",
            args.key_name
            ],
        "register_module": [
            "comx",
            "module",
            "register",
            f"{args.module_path}",
            f"{args.ip_address}",
            f"{args.port}",
            f"{args.key_name}",
            "--netuid",
            f"{args.netuid}"
            ],
        "update_module": [
            "comx", 
            "module", 
            "update", 
            f"{args.key_name}", 
            f"{args.ip_address}", 
            f"{args.port}", 
            f"{args.module_path}", 
            "--netuid", 
            f"{args.netuid}"]
    }
    command = command_map[command_choice]
    process = start_detached_process(command)
    monitor_process(process)

def monitor_process(process: Popen[str]):
    """ Monitor the process output in real-time. """
    try:
        stdout, stderr = process.communicate()
        print("Output:", stdout)
        if stderr:
            print("Error:", stderr)
    except Exception as e:
        print("An error occurred:", e)

args = argparse.ArgumentParser()
args.add_argument("--ip_address", required=False, type=str, default="127.0.0.1")
args.add_argument("--port", required=False, type=int, default=5000)
args.add_argument("--netuid", required=False, type=str, default="3")
args.add_argument("--key_name", required=False, type=str, default="key")
args.add_argument("--module_path", required=False, type=str, default="synthia.miner.anthropic.AnthropicModule")
args = args.parse_args()

if __name__ == "__main__":
    args.netuid = "3"
    args.ip_address = "216.81.245.26"
    reg_moduel = "register_module"
    reg_vali = "register_validator"
    serve_module = "serve_miner"


    for i in range(13):
        args.port = str(50050 + i * 5)
        args.module_path = f"anthropic{i}.AnthropicModule"
        args.key_name = f"anthropic{i}.AnthropicModule"
        #run_command(reg_moduel, args)
        run_command(serve_module, args)
        
    for i in range(7):
        args.module_path = f"text_validator{i}.TextValdiator"
        args.key_name = f"text_validator{i}.TextValdiator"
        #run_command(reg_vali, args)
        run_command(serve_module, args)