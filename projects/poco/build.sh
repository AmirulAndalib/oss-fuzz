#!/bin/bash -eu
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

mkdir cmake-build
cd cmake-build
cmake -DBUILD_SHARED_LIBS=OFF -DENABLE_ACTIVERECORD=OFF \
      -DENABLE_ACTIVERECORD_COMPILER=OFF -DENABLE_TESTS=OFF \
      -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF \
      -DENABLE_DATA_SQLITE=OFF -DENABLE_REDIS=OFF -DENABLE_MONGODB=OFF \
      -DENABLE_PROMETHEUS=OFF \
      ..
make -j$(nproc)

$CXX $CXXFLAGS -DPOCO_HAVE_FD_EPOLL -DPOCO_OS_FAMILY_UNIX \
    -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    -D_REENTRANT -D_THREAD_SAFE -D_XOPEN_SOURCE=500 \
    -I/src/poco/JSON/include \
    -I/src/poco/Foundation/include \
    -O2 -g -DNDEBUG -std=c++17 \
    -o json_fuzzer.o -c $SRC/json_parse_fuzzer.cc

$CXX $CXXFLAGS $LIB_FUZZING_ENGINE json_fuzzer.o \
    ./lib/libPocoJSON.a \
    ./lib/libPocoFoundation.a \
    -o $OUT/json_parser_fuzzer -lpthread -ldl -lrt

$CXX $CXXFLAGS -DPOCO_HAVE_FD_EPOLL -DPOCO_OS_FAMILY_UNIX \
    -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    -D_REENTRANT -D_THREAD_SAFE -D_XOPEN_SOURCE=500 \
    -I/src/poco/XML/include \
    -I/src/poco/Foundation/include \
    -O2 -g -DNDEBUG -std=c++17 \
    -o xml_fuzzer.o -c $SRC/xml_parse_fuzzer.cc

$CXX $CXXFLAGS $LIB_FUZZING_ENGINE xml_fuzzer.o \
    ./lib/libPocoXML.a \
    ./lib/libPocoFoundation.a \
    -o $OUT/xml_parser_fuzzer -lpthread -ldl -lrt

$CXX $CXXFLAGS -DPOCO_HAVE_FD_EPOLL -DPOCO_OS_FAMILY_UNIX \
    -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    -D_REENTRANT -D_THREAD_SAFE -D_XOPEN_SOURCE=500 \
    -I/src/poco/Foundation/include \
    -O2 -g -DNDEBUG -std=c++17 \
    -o date_time_fuzzer.o -c $SRC/date_time_fuzzer.cc

$CXX $CXXFLAGS $LIB_FUZZING_ENGINE date_time_fuzzer.o \
    ./lib/libPocoFoundation.a \
    -o $OUT/date_time_fuzzer -lpthread -ldl -lrt

$CXX $CXXFLAGS -DPOCO_HAVE_FD_EPOLL -DPOCO_OS_FAMILY_UNIX \
    -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    -D_REENTRANT -D_THREAD_SAFE -D_XOPEN_SOURCE=500 \
    -I/src/poco/JWT/include \
    -I/src/poco/Foundation/include \
    -I/src/poco/JSON/include \
    -I/src/poco/Crypto/include \
    -O2 -g -DNDEBUG -std=c++17 \
    -o jwt_decode_fuzzer.o -c $SRC/jwt_decode_fuzzer.cc

$CXX $CXXFLAGS $LIB_FUZZING_ENGINE jwt_decode_fuzzer.o \
    ./lib/libPocoJWT.a \
    ./lib/libPocoJSON.a \
    ./lib/libPocoFoundation.a \
    ./lib/libPocoCrypto.a \
    -o $OUT/jwt_decode_fuzzer -lpthread -ldl -lrt -lssl -lcrypto

$CXX $CXXFLAGS -DPOCO_HAVE_FD_EPOLL -DPOCO_OS_FAMILY_UNIX \
    -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    -D_REENTRANT -D_THREAD_SAFE -D_XOPEN_SOURCE=500 \
    -I/src/poco/Foundation/include \
    -I/src/poco/Net/include \
    -O2 -g -DNDEBUG -std=c++17 \
    -o http_message_fuzzer.o -c $SRC/http_message_fuzzer.cc

$CXX $CXXFLAGS $LIB_FUZZING_ENGINE http_message_fuzzer.o \
    ./lib/libPocoNet.a \
    ./lib/libPocoFoundation.a \
    -o $OUT/http_message_fuzzer -lpthread -ldl -lrt

$CXX $CXXFLAGS -DPOCO_HAVE_FD_EPOLL -DPOCO_OS_FAMILY_UNIX \
    -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE \
    -D_REENTRANT -D_THREAD_SAFE -D_XOPEN_SOURCE=500 \
    -I/src/poco/Foundation/include \
    -I/src/poco/Net/include \
    -O2 -g -DNDEBUG -std=c++17 \
    -o mail_message_fuzzer.o -c $SRC/mail_message_fuzzer.cc

$CXX $CXXFLAGS $LIB_FUZZING_ENGINE mail_message_fuzzer.o \
    ./lib/libPocoNet.a \
    ./lib/libPocoFoundation.a \
    -o $OUT/mail_message_fuzzer -lpthread -ldl -lrt

cp $SRC/xml.dict $OUT/xml_parser_fuzzer.dict
