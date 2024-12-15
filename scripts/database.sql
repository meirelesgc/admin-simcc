CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE TYPE relationship AS ENUM ('COLABORADOR', 'PERMANENTE');
CREATE TABLE IF NOT EXISTS public.institution(
      institution_id uuid DEFAULT uuid_generate_v4(),
      name VARCHAR(255) NOT NULL,
      acronym VARCHAR(50) UNIQUE,
      lattes_id CHAR(16),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (institution_id)
);
CREATE TABLE IF NOT EXISTS public.researcher(
      researcher_id uuid NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
      name VARCHAR(150) NOT NULL,
      lattes_id VARCHAR(20),
      institution_id uuid NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (lattes_id, institution_id),
      FOREIGN KEY (institution_id) REFERENCES institution (institution_id)
);
CREATE TABLE IF NOT EXISTS public.graduate_program(
      graduate_program_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      code VARCHAR(100),
      name VARCHAR(100) NOT NULL,
      area VARCHAR(100) NOT NULL,
      modality VARCHAR(100) NOT NULL,
      TYPE VARCHAR(100) NULL,
      rating VARCHAR(5),
      institution_id uuid NOT NULL,
      state character varying(4) DEFAULT 'BA'::character varying,
      city character varying(100) DEFAULT 'Salvador'::character varying,
      region character varying(100) DEFAULT 'Nordeste'::character varying,
      url_image VARCHAR(200) NULL,
      acronym character varying(100),
      description TEXT,
      visible bool DEFAULT FALSE,
      site TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (graduate_program_id),
      FOREIGN KEY (institution_id) REFERENCES institution (institution_id)
);
CREATE TABLE IF NOT EXISTS public.graduate_program_researcher(
      graduate_program_id uuid NOT NULL,
      researcher_id uuid NOT NULL,
      year INT [],
      type_ relationship,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (graduate_program_id, researcher_id),
      FOREIGN KEY (researcher_id) REFERENCES researcher (researcher_id),
      FOREIGN KEY (graduate_program_id) REFERENCES graduate_program (graduate_program_id)
);
CREATE TABLE IF NOT EXISTS public.graduate_program_student(
      graduate_program_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      researcher_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      year INT [],
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (graduate_program_id, researcher_id, year),
      FOREIGN KEY (researcher_id) REFERENCES researcher (researcher_id),
      FOREIGN KEY (graduate_program_id) REFERENCES graduate_program (graduate_program_id)
);
CREATE TABLE IF NOT EXISTS public.weights (
      institution_id uuid DEFAULT uuid_generate_v4(),
      a1 numeric(20, 3),
      a2 numeric(20, 3),
      a3 numeric(20, 3),
      a4 numeric(20, 3),
      b1 numeric(20, 3),
      b2 numeric(20, 3),
      b3 numeric(20, 3),
      b4 numeric(20, 3),
      c numeric(20, 3),
      sq numeric(20, 3),
      book numeric(20, 3),
      book_chapter numeric(20, 3),
      software character varying,
      patent_granted character varying,
      patent_not_granted character varying,
      report character varying,
      f1 numeric(20, 3) DEFAULT 0,
      f2 numeric(20, 3) DEFAULT 0,
      f3 numeric(20, 3) DEFAULT 0,
      f4 numeric(20, 3) DEFAULT 0,
      f5 numeric(20, 3) DEFAULT 0
);
CREATE TABLE roles (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      role VARCHAR(255) NOT NULL
);
CREATE TABLE permission (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
      permission VARCHAR(255) NOT NULL
);
CREATE SCHEMA IF NOT EXISTS UFMG;
CREATE TABLE IF NOT EXISTS UFMG.researcher (
      id uuid,
      researcher_id uuid,
      matric character varying(200),
      inscUFMG character varying(200),
      nome character varying(200),
      genero character varying(40),
      situacao character varying(40),
      rt character varying(40),
      clas character varying(200),
      cargo character varying(40),
      classe character varying(40),
      ref character varying(200),
      titulacao character varying(40),
      entradaNaUFMG DATE,
      progressao DATE,
      semester character varying(6),
      FOREIGN KEY (researcher_id) REFERENCES public.researcher (researcher_id)
);
CREATE TABLE IF NOT EXISTS UFMG.technician (
      technician_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      matric VARCHAR(255),
      ins_ufmg VARCHAR(255),
      nome VARCHAR(255),
      genero VARCHAR(50),
      deno_sit VARCHAR(255),
      rt VARCHAR(255),
      classe VARCHAR(255),
      cargo VARCHAR(255),
      nivel VARCHAR(255),
      ref VARCHAR(255),
      titulacao VARCHAR(255),
      setor VARCHAR(255),
      detalhe_setor VARCHAR(255),
      dting_org DATE,
      data_prog DATE,
      semester character varying(6),
      PRIMARY KEY (technician_id)
);
CREATE TABLE IF NOT EXISTS ufmg.departament (
      dep_id VARCHAR(20),
      org_cod VARCHAR(3),
      dep_nom VARCHAR(100),
      dep_des TEXT,
      dep_email VARCHAR(100),
      dep_site VARCHAR(100),
      dep_sigla VARCHAR(30),
      dep_tel VARCHAR(20),
      img_data BYTEA,
      PRIMARY KEY (dep_id)
);
CREATE TABLE IF NOT EXISTS ufmg.departament_technician (
      dep_id character varying(10),
      technician_id uuid,
      PRIMARY KEY (dep_id, technician_id),
      FOREIGN KEY (dep_id) REFERENCES ufmg.departament (dep_id),
      FOREIGN KEY (technician_id) REFERENCES ufmg.technician (technician_id)
);
CREATE TABLE IF NOT EXISTS UFMG.departament_researcher (
      dep_id VARCHAR(20),
      researcher_id uuid NOT NULL,
      PRIMARY KEY (dep_id, researcher_id),
      FOREIGN KEY (dep_id) REFERENCES UFMG.departament (dep_id),
      FOREIGN KEY (researcher_id) REFERENCES public.researcher (researcher_id)
);
CREATE TABLE UFMG.disciplines (
      dep_id VARCHAR(20),
      id VARCHAR(20),
      semester VARCHAR(20),
      department VARCHAR(255),
      academic_activity_code VARCHAR(255),
      academic_activity_name VARCHAR(255),
      academic_activity_ch VARCHAR(255),
      demanding_courses VARCHAR(255),
      oft VARCHAR(50),
      available_slots VARCHAR(50),
      occupied_slots VARCHAR(50),
      percent_occupied_slots VARCHAR(50),
      schedule VARCHAR(255),
      language VARCHAR(50),
      researcher_id uuid [],
      researcher_name VARCHAR [],
      status VARCHAR(50),
      workload VARCHAR []
);
CREATE TABLE incite_graduate_program(
      incite_graduate_program_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      name VARCHAR(255) NOT NULL,
      description VARCHAR(500) NULL,
      link VARCHAR(500) NULL,
      institution_id uuid NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      visible bool DEFAULT FALSE,
      PRIMARY KEY (incite_graduate_program_id),
      FOREIGN KEY (institution_id) REFERENCES institution (institution_id)
);
CREATE TABLE incite_graduate_program_researcher(
      incite_graduate_program_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      researcher_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (incite_graduate_program_id, researcher_id),
      FOREIGN KEY (researcher_id) REFERENCES researcher (researcher_id),
      FOREIGN KEY (incite_graduate_program_id) REFERENCES incite_graduate_program (incite_graduate_program_id)
);
CREATE TABLE users (
      user_id uuid NOT NULL DEFAULT uuid_generate_v4(),
      display_name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      uid VARCHAR(255) UNIQUE NOT NULL,
      photo_url TEXT,
      lattes_id VARCHAR(255),
      institution_id uuid,
      provider VARCHAR(255),
      linkedin VARCHAR(255),
      verify bool DEFAULT FALSE,
      PRIMARY KEY (user_id)
);
CREATE TABLE users_roles (
      role_id UUID NOT NULL,
      user_id UUID NOT NULL,
      PRIMARY KEY (role_id, user_id),
      FOREIGN KEY (user_id) REFERENCES public.users (user_id)
);
CREATE TABLE newsletter_subscribers (
      id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
      email VARCHAR(255) NOT NULL UNIQUE,
      subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    rating INTEGER CHECK (rating >= 0 AND rating <= 10) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO public.institution (
            institution_id,
            name,
            acronym,
            lattes_id,
            created_at,
            updated_at
      )
VALUES (
            '083a16f0-cccf-47d2-a676-d10b8931f66b',
            'Universidade Federal de Minas Gerais',
            'UFMG',
            '',
            '2024-08-21 15:43:32.621733',
            '2024-08-21 15:43:32.621733'
      ),
      (
            '083a16f0-cccf-47d2-a676-d10b8931f66a',
            'SENAI CIMATEC',
            'CIMATEC',
            '',
            '2024-08-21 15:43:32.621733',
            '2024-08-21 15:43:32.621733'
      );
INSERT INTO roles (id, role)
VALUES (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'Manutenção'
      );
INSERT INTO permission (role_id, permission)
VALUES (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_modulo_administrativo'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_gerencia_modulo_administrativo'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_cargos_permissoes'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_cargos_usuarios'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_informacoes_usuarios'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_configuracoes_plataforma'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'atualizar_apache_hop'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_todos_departamentos'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_todos_programas'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_informacoes_programa'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_informacoes_departamento'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_docentes_programa'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_discentes_programa'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_docentes_departamento'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_tecnicos_departamento'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_pesos_avaliacao'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_indicadores_instituicao'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_grupos_pesquisa'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_inct'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_indicadores_pos_graduacao'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'adicionar_programa'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'deletar_programa'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'adicionar_departamento'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'deletar_departamento'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'criar_barema_avaliacao'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'enviar_notificacoes'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'editar_pesquisadores'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_pesquisadores'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'visualizar_indices_pesquisador'
      );
INSERT INTO users (
            user_id,
            display_name,
            email,
            uid,
            photo_url,
            lattes_id,
            provider,
            linkedin,
            institution_id
      )
VALUES (
            '9b7c08e3-f14c-40d7-b445-d7b8167d9437',
            'Conectee',
            'conectee.eng@gmail.com',
            'j5Fgp4jRSGhPVLq9WNqqfUE00P32',
            'https://lh3.googleusercontent.com/a/ACg8ocJWtAJdH1Lt2X5f9bdAnKhr7GlJHNPomCo6xxdoGDgFqONMsw=s96-c',
            '6716225567627323',
            'google',
            '',
            '083a16f0-cccf-47d2-a676-d10b8931f66b'
      ),
      (
            '30a2c264-af11-4043-a3ce-4f2bf1ed03c3',
            'Gleidson Costa',
            'geucosta167@gmail.com',
            'dnmdspfXXkbTl8oHGGRYjkOyzHY2',
            'https://lh3.googleusercontent.com/a/ACg8ocLu4zWxxOFI9Vtl-x4UvwNhtlV0YO09JLfL9biGDY3agHQreA=s96-c',
            '',
            'google',
            '',
            '083a16f0-cccf-47d2-a676-d10b8931f66b'
      ),
      (
            'ecbfc3e8-8221-41ec-b20c-00712f88b148',
            'Victor Hugo de Jesus Oliveira',
            'victorhugodejesus2004@hotmail.com',
            'XSVw3AnnpXMM91qEAaWAPVvI0M52',
            'None',
            '',
            'google',
            '',
            '083a16f0-cccf-47d2-a676-d10b8931f66b'
      ),
      (
            'fa000ca8-9231-41a6-887d-54598995528b',
            'Eduardo M F Jorge',
            'emjorge1974@gmail.com',
            'lOAKfTIKnObOOt3FijCVopCgtOj2',
            'https://lh3.googleusercontent.com/a/ACg8ocIo7rKtveFIq0V7JjRz0MblwmY8CqbASvZYQifyFf1PvpRrtA=s96-c',
            '6716225567627323',
            'google',
            '',
            '083a16f0-cccf-47d2-a676-d10b8931f66b'
      );
INSERT INTO users_roles (role_id, user_id)
VALUES (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            '9b7c08e3-f14c-40d7-b445-d7b8167d9437'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            '30a2c264-af11-4043-a3ce-4f2bf1ed03c3'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'ecbfc3e8-8221-41ec-b20c-00712f88b148'
      ),
      (
            '2094ba5c-a5b3-4bcb-81e4-f5c323eab0ed',
            'fa000ca8-9231-41a6-887d-54598995528b'
      );