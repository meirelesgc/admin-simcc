import json
import os
import subprocess
import requests
from http import HTTPStatus

import psycopg2
from flask import Blueprint, jsonify, request, send_file
from pydantic import ValidationError

from ..dao import dao_system
from ..models import FeedbackSchema, UserModel

rest_system = Blueprint("rest_system_management", __name__)
HOP_LOCK_FILE_PATH = os.getenv("HOP_LOCK_FILE_PATH", "/tmp/hop_execution.lock")
HOP_LOG_FILE_PATH = os.getenv("HOP_LOG_FILE_PATH")
HOP_ROUTINE_PATH = os.getenv("HOP_ROUTINE_PATH")


@rest_system.route("/s/user", methods=["POST"])
def create_user():
    try:
        user = request.get_json()
        user = UserModel(**user[0])
        dao_system.create_user(user)
        return jsonify("OK"), HTTPStatus.CREATED
    except psycopg2.errors.UniqueViolation:
        return jsonify({"message": "discente já cadastrado"}), HTTPStatus.CONFLICT


# @rest_system.route("/s/ufmg/user", methods=["GET"])
# def create_ufmg_user():
#     try:
#         all_headers = dict(request.headers)
#         user = {
#             "displayName": all_headers["Shib-Person-Commonname"],
#             "email": all_headers["Shib-Person-Mail"],
#             "uid": all_headers["Shib-Person-Uid"],
#             "provider": "shib",
#         }
#         user = UserModel(**user)
#         dao_system.create_user(user)
#         user = dao_system.select_user(user.uid)
#         return jsonify(user), HTTPStatus.CREATED

#     except psycopg2.errors.UniqueViolation:
#         user = dao_system.select_user(user.uid)
#         return jsonify(user), HTTPStatus.OK


@rest_system.route("/s/user", methods=["GET"])
def select_user():
    uid = request.args.get("uid")
    user = dao_system.select_user(uid)
    return jsonify(user), HTTPStatus.OK


@rest_system.route("/s/user/all", methods=["GET"])
def list_users():
    user = dao_system.list_users()
    return jsonify(user), HTTPStatus.OK


@rest_system.route("/s/user/entrys", methods=["GET"])
def list_all_users():
    user = dao_system.list_all_users()
    return jsonify(user), HTTPStatus.OK


@rest_system.route("/s/user", methods=["PUT"])
def update_user():
    user = request.get_json()
    dao_system.update_user(user[0])
    return jsonify(), HTTPStatus.OK


@rest_system.route("/s/save-directory", methods=["POST"])
def save_directory():
    data = request.json
    directory = data.get("directory")

    if not directory:
        return jsonify({"error": "No directory provided"}), 400

    try:
        with open("files/directory.json", "w", encoding="utf-8") as file:
            json.dump({"directory": directory}, file)
        return jsonify({"message": "Directory saved successfully"}), 200
    except Exception as e:
        print("Error saving directory:", e)
        return jsonify({"error": "Failed to save directory"}), 500


@rest_system.route("/s/directory", methods=["GET"])
def get_directory():
    try:
        with open("files/directory.json", "r") as file:
            data = json.load(file)
            directory_path = data.get("directory")
        if not directory_path:
            return jsonify({"error": "Directory path not found"}), 404

        directory_list = os.listdir(directory_path)
        return jsonify(directory_list)
    except FileNotFoundError:
        return jsonify({"error": "Directory file not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@rest_system.route("/s/role", methods=["POST"])
def create_new_role():
    role = request.get_json()
    dao_system.create_new_role(role)
    return jsonify("OK"), HTTPStatus.CREATED


@rest_system.route("/s/role", methods=["GET"])
def view_roles():
    roles = dao_system.view_roles()
    return jsonify(roles), HTTPStatus.OK


@rest_system.route("/s/role", methods=["PUT"])
def update_role():
    role = request.get_json()
    dao_system.update_role(role)
    return jsonify("OK"), HTTPStatus.CREATED


@rest_system.route("/s/role", methods=["DELETE"])
def delete_role():
    role = request.get_json()
    dao_system.delete_role(role)
    return jsonify(), HTTPStatus.OK


@rest_system.route("/s/permission", methods=["POST"])
def create_new_permission():
    permission = request.get_json()
    dao_system.create_new_permission(permission)
    return jsonify("OK"), HTTPStatus.CREATED


@rest_system.route("/s/permission", methods=["GET"])
def permissions_view():
    role_id = request.args.get("role_id")
    roles = dao_system.permissions_view(role_id)
    return jsonify(roles), HTTPStatus.OK


@rest_system.route("/s/permission", methods=["PUT"])
def update_permission():
    permission = request.get_json()
    dao_system.update_permission(permission)
    return jsonify("OK"), HTTPStatus.CREATED


@rest_system.route("/s/permission", methods=["DELETE"])
def delete_permission():
    permission = request.get_json()
    dao_system.delete_permission(permission)
    return jsonify("OK"), HTTPStatus.NO_CONTENT


@rest_system.route("/s/user/role", methods=["POST"])
def assign_user():
    try:
        user = request.get_json()
        dao_system.assign_user(user)
        return jsonify("OK"), HTTPStatus.CREATED
    except psycopg2.errors.UniqueViolation:
        return jsonify({"message": "discente já cadastrado"}), HTTPStatus.CONFLICT


@rest_system.route("/s/user/permissions", methods=["GET"])
def view_user_roles():
    uid = request.args.get("uid")
    role_id = request.args.get("role_id")
    permissions = dao_system.view_user_roles(uid, role_id)
    return jsonify(permissions), HTTPStatus.OK


@rest_system.route("/s/user/role", methods=["DELETE"])
def unassign_user():
    technician = request.get_json()
    dao_system.unassign_user(technician)
    return jsonify("OK"), HTTPStatus.NO_CONTENT


@rest_system.route("/s/hop", methods=["POST"])
def hop():
    try:
        if os.path.exists(HOP_LOCK_FILE_PATH):
            response = {
                "status": "error",
                "message": "A previous execution is still in progress. Please try again later.",
            }
            return jsonify(response), HTTPStatus.TOO_MANY_REQUESTS

        with open(HOP_LOCK_FILE_PATH, "w") as lock_file:
            lock_file.write("locked")

        subprocess.Popen([HOP_ROUTINE_PATH], shell=True)

        response = {
            "status": "success",
            "message": "Apache Hop execution started successfully.",
        }
        return jsonify(response), HTTPStatus.OK

    except Exception as e:
        if os.path.exists(HOP_LOCK_FILE_PATH):
            os.remove(HOP_LOCK_FILE_PATH)

        response = {
            "status": "error",
            "message": f"An error occurred: {str(e)}",
        }
        return jsonify(response), HTTPStatus.INTERNAL_SERVER_ERROR


@rest_system.route("/s/hop", methods=["GET"])
def get_last_log_line():
    try:
        if not os.path.exists(HOP_LOG_FILE_PATH):
            return (
                jsonify({"status": "error", "message": "Log file not found."}),
                HTTPStatus.NOT_FOUND,
            )

        with open(HOP_LOG_FILE_PATH, "r") as log_file:
            lines = log_file.readlines()
            last_line = lines[-1].strip() if lines else "Log file is empty."

        return jsonify({"status": "success", "message": last_line}), HTTPStatus.OK

    except Exception as e:
        return (
            jsonify({"status": "error", "message": f"An error occurred: {str(e)}"}),
            HTTPStatus.INTERNAL_SERVER_ERROR,
        )


@rest_system.route("/s/feedback", methods=["POST"])
def feedback():
    try:
        feedback_data = FeedbackSchema(**request.json)
        dao_system.add_feedback(feedback_data)
        return (
            jsonify(
                {
                    "message": "Feedback recebido com sucesso!",
                    "data": feedback_data.dict(),
                }
            ),
            200,
        )
    except ValidationError as e:
        return jsonify({"message": "Validation error", "errors": e.errors()}), 400


UPLOAD_FOLDER = os.path.join(os.getcwd(), "files", "imagens")
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@rest_system.route("/upload/<id>", methods=["POST"])
def upload_image(id):
    print(id)
    if "file" not in request.files:
        return "Nenhum arquivo enviado", 400

    file = request.files["file"]
    if file.filename == "":
        return "Nenhum arquivo selecionado", 400
    extension = file.filename.rsplit(".", 1)[1] if "." in file.filename else "jpg"
    file_path = os.path.join(UPLOAD_FOLDER, f"{id}.{extension}")
    file.save(file_path)

    return "Imagem salva com sucesso", 200


@rest_system.route("/image/<id>", methods=["GET"])
def get_image(id):

    for extension in ["jpg", "jpeg", "png", "gif"]:
        file_path = os.path.join(UPLOAD_FOLDER, f"{id}.{extension}")
        if os.path.isfile(file_path):
            return send_file(file_path)

    return "ok"


@rest_system.route("/group_production", methods=["POST"])
def post_group():
    producion = request.get_json()
    dao_system.add_group_producion(producion)
    return "ok"

@rest_system.route("/deletarimagem/<id>", methods=["DELETE"])
def delete_image(id):

    for extension in ["jpg", "jpeg", "png", "gif"]:
        file_path = os.path.join(UPLOAD_FOLDER, f"{id}.{extension}")
        print(f"Procurando arquivo: {file_path}")
        if os.path.exists(file_path):
            try:
                os.remove(file_path)
                return "Imgem deletada com sucesso"
            except Exception as e:
                return {"error": f"Erro ao deletar a imagem: {str(e)}"}, 500
    
    return {"error": "Imagem não encontrada"}, 404