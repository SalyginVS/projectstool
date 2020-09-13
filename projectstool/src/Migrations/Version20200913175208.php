<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20200913175208 extends AbstractMigration
{
    public function getDescription() : string
    {
        return '';
    }

    public function up(Schema $schema) : void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE user_user_networks ALTER user_id TYPE UUID');
        $this->addSql('ALTER TABLE user_user_networks ALTER user_id DROP DEFAULT');
        $this->addSql('ALTER TABLE user_users ADD new_email VARCHAR(255) DEFAULT NULL');
        $this->addSql('ALTER TABLE user_users ADD new_email_token VARCHAR(255) DEFAULT NULL');
        $this->addSql('ALTER TABLE user_users ALTER id TYPE UUID');
        $this->addSql('ALTER TABLE user_users ALTER id DROP DEFAULT');
        $this->addSql('ALTER TABLE user_users ALTER email TYPE VARCHAR(255)');
        $this->addSql('ALTER TABLE user_users ALTER email DROP DEFAULT');
        $this->addSql('ALTER TABLE user_users ALTER role TYPE VARCHAR(16)');
        $this->addSql('ALTER TABLE user_users ALTER role DROP DEFAULT');
    }

    public function down(Schema $schema) : void
    {
        // this down() migration is auto-generated, please modify it to your needs
        //$this->addSql('CREATE SCHEMA public');
        $this->addSql('ALTER TABLE user_users DROP new_email');
        $this->addSql('ALTER TABLE user_users DROP new_email_token');
        $this->addSql('ALTER TABLE user_users ALTER id TYPE UUID');
        $this->addSql('ALTER TABLE user_users ALTER id DROP DEFAULT');
        $this->addSql('ALTER TABLE user_users ALTER email TYPE VARCHAR(255)');
        $this->addSql('ALTER TABLE user_users ALTER email DROP DEFAULT');
        $this->addSql('ALTER TABLE user_users ALTER role TYPE VARCHAR(16)');
        $this->addSql('ALTER TABLE user_users ALTER role DROP DEFAULT');
        $this->addSql('ALTER TABLE user_user_networks ALTER user_id TYPE UUID');
        $this->addSql('ALTER TABLE user_user_networks ALTER user_id DROP DEFAULT');
    }
}
