FROM dlanguage/dmd
ENV \
  COMPILER=dmd \
  COMPILER_VERSION=2.080.0 \
  PATH=/dlang/dub:/dlang/${COMPILER}-${COMPILER_VERSION}/linux/bin64:${PATH} \
  LD_LIBRARY_PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/linux/lib64 \
  LIBRARY_PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/linux/lib64 \
  PS1="(${COMPILER}-${COMPILER_VERSION}) \\u@\\h:\\w\$"
RUN apt-get update; apt-get install -y time
ENTRYPOINT ["/entrypoint.sh"]
CMD ["${COMPILER}"]
