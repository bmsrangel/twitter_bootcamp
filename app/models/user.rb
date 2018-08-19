class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :tweets
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy #Atribui um "apelido" definindo o que será acessado ao chamar o :active_relationships
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy #Atribui um "apelido" definindo o que será acessado ao chamar o :passive_relationships
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  #Cria o relacionamento entre um usuário e outro
  def follow!(other_user) #O ! é uma boa prática. Geralmente usado em métodos que instanciam e salvam no banco de dados
    following << other_user
    #active_relationships.create(followed: other_user)
  end

  #Apaga o relacionamento entre um usuário e outro
  def unfollow!(other_user)
    following.delete(other_user)
  end

  #Verifica se um usuário está seguindo outro
  def following?(other_user)
    following.include?(other_user)
  end

  def feed
    user_ids = following.pluck(:id)
    user_ids << self.id
    Tweet.where(user_id: user_ids).order(created_at: :desc)
  end

end
