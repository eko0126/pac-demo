#Copyright [eko0126] [name of copyright owner]
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

FROM amazoncorretto:11.0.12 as build
COPY build/libs/ /app/build/libs/
COPY entrypoint /app/


FROM amazoncorretto:11.0.12
COPY --from=build /app/ /app/
ENTRYPOINT /app/entrypoint