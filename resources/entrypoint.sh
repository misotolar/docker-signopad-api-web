#!/bin/sh

set -ex

exec "$@" "${SIGNOPAD_ADDRESS}" "${SIGNOPAD_PORT}"
